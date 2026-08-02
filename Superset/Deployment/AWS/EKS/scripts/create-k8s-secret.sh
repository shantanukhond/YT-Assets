#!/usr/bin/env bash
# Creates/updates the Kubernetes secret from AWS Secrets Manager
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REGION="${AWS_REGION:-ap-south-1}"
SECRET_ID="${SECRET_ID:-superset-eks-dev/superset}"
NAMESPACE="${NAMESPACE:-superset}"

echo "Reading secret: $SECRET_ID ($REGION)"
JSON=$(aws secretsmanager get-secret-value --region "$REGION" --secret-id "$SECRET_ID" --query SecretString --output text)

SUPERSET_SECRET_KEY=$(echo "$JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['SUPERSET_SECRET_KEY'])")
DATABASE_URL=$(echo "$JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['DATABASE_URL'])")
REDIS_URL=$(echo "$JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['REDIS_URL'])")
SUPERSET_ADMIN_PASSWORD=$(echo "$JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['SUPERSET_ADMIN_PASSWORD'])")

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic superset-secrets \
  --namespace "$NAMESPACE" \
  --from-literal=SUPERSET_SECRET_KEY="$SUPERSET_SECRET_KEY" \
  --from-literal=DATABASE_URL="$DATABASE_URL" \
  --from-literal=REDIS_URL="$REDIS_URL" \
  --from-literal=SUPERSET_ADMIN_PASSWORD="$SUPERSET_ADMIN_PASSWORD" \
  --from-literal=SUPERSET_ADMIN_USERNAME="${SUPERSET_ADMIN_USERNAME:-admin}" \
  --from-literal=SUPERSET_ADMIN_EMAIL="${SUPERSET_ADMIN_EMAIL:-admin@example.com}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secret applied in namespace/$NAMESPACE"
