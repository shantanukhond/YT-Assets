#!/usr/bin/env bash
# Install AWS Load Balancer Controller + apply Superset manifests
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REGION="${AWS_REGION:-ap-south-1}"
CLUSTER_NAME="${CLUSTER_NAME:-superset-eks-dev}"
ROLE_ARN="${ALB_CONTROLLER_ROLE_ARN:?Set ALB_CONTROLLER_ROLE_ARN from terraform output}"
CERT_ARN="${CERTIFICATE_ARN:?Set CERTIFICATE_ARN from terraform output}"
DOMAIN="${DOMAIN_NAME:-app.superset.atwish.org}"
ZONE_ID="${ROUTE53_ZONE_ID:?Set ROUTE53_ZONE_ID}"

aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

helm repo add eks https://aws.github.io/eks-charts
helm repo update

kubectl apply -f https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName="$CLUSTER_NAME" \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="$ROLE_ARN"

# Patch ingress with cert ARN + domain
sed \
  -e "s|CERTIFICATE_ARN|$CERT_ARN|g" \
  -e "s|app.superset.atwish.org|$DOMAIN|g" \
  "$ROOT/k8s/06-ingress.yaml" > /tmp/superset-ingress.yaml

"$ROOT/scripts/create-k8s-secret.sh"

kubectl apply -f "$ROOT/k8s/00-namespace.yaml"
kubectl apply -f "$ROOT/k8s/01-configmap.yaml"
kubectl apply -f "$ROOT/k8s/03-web.yaml"
kubectl apply -f "$ROOT/k8s/04-worker.yaml"
kubectl apply -f "$ROOT/k8s/05-beat.yaml"
kubectl apply -f /tmp/superset-ingress.yaml

echo "Waiting for ALB address..."
for i in $(seq 1 60); do
  ALB_HOST=$(kubectl get ingress superset -n superset -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
  if [[ -n "$ALB_HOST" ]]; then
    echo "ALB: $ALB_HOST"
    ALB_ZONE=$(aws elbv2 describe-load-balancers --region "$REGION" \
      --query "LoadBalancers[?DNSName=='$ALB_HOST'].CanonicalHostedZoneId | [0]" --output text)
    aws route53 change-resource-record-sets --hosted-zone-id "$ZONE_ID" --change-batch "{
      \"Changes\": [{
        \"Action\": \"UPSERT\",
        \"ResourceRecordSet\": {
          \"Name\": \"$DOMAIN\",
          \"Type\": \"A\",
          \"AliasTarget\": {
            \"HostedZoneId\": \"$ALB_ZONE\",
            \"DNSName\": \"$ALB_HOST\",
            \"EvaluateTargetHealth\": true
          }
        }
      }]
    }"
    echo "DNS upserted: https://$DOMAIN → $ALB_HOST"
    exit 0
  fi
  sleep 10
done

echo "Timed out waiting for ALB. Check: kubectl describe ingress -n superset"
exit 1
