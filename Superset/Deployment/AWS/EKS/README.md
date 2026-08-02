# Deploy Apache Superset on AWS EKS

Same architecture as the ECS guide, but workloads run on **Kubernetes (EKS)**.
Uses the ready-made `apache/superset` image — no ECR needed.

## Architecture

![Superset AWS EKS Deployment Architecture](./Superset%20AWS%20EKS%20Deployment%20Architecture.png)

```
Internet
   │  app.superset.atwish.org (Route53 + ACM)
   ▼
┌──────────────── AWS Cloud ───────────────────────┐
│  Route53 · ACM · Secrets Manager · CloudWatch    │
│                                                  │
│  ┌────────────────── VPC ─────────────────────┐  │
│  │ PUBLIC          PRIVATE APP                │  │
│  │ IGW / ALB / NAT → EKS (web/worker/beat)    │  │
│  │                     │                      │  │
│  │              PRIVATE DATA                  │  │
│  │              RDS + Redis                   │  │
│  └────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

| Subnet | What lives there | Internet |
|---|---|---|
| Public | ALB (via Ingress), NAT | Yes (IGW) |
| Private app | EKS nodes + pods | Outbound via NAT |
| Private data | RDS + Redis | None |

## ECS vs EKS (same ideas)

| Concern | ECS | EKS |
|---|---|---|
| Compute | Fargate tasks | EKS managed node group |
| web / worker / beat | 3 ECS services | 3 Deployments |
| Load balancer | ALB + target group | Ingress → AWS LB Controller → ALB |
| Config | env base64 at start | ConfigMap mounted as file |
| Secrets | ECS secrets injection | K8s Secret (from Secrets Manager) |
| Scaling | App Auto Scaling | HPA (web + worker); beat = 1 |

## Prerequisites

- AWS CLI, Terraform >= 1.5, kubectl, helm
- Route53 public zone for `atwish.org`
- Permissions for EKS, VPC, RDS, ElastiCache, IAM, ACM, Route53

## 1) Deploy infrastructure

```bash
cd terraform
terraform init
terraform apply
```

Useful outputs:

```bash
terraform output configure_kubectl
terraform output -raw certificate_arn
terraform output -raw alb_controller_role_arn
terraform output -raw superset_admin_password
```

## 2) Deploy AWS LB Controller + Superset

```bash
cd ..

export AWS_REGION=ap-south-1
export CLUSTER_NAME=$(cd terraform && terraform output -raw cluster_name)
export ALB_CONTROLLER_ROLE_ARN=$(cd terraform && terraform output -raw alb_controller_role_arn)
export CERTIFICATE_ARN=$(cd terraform && terraform output -raw certificate_arn)
export ROUTE53_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name atwish.org --query 'HostedZones[0].Id' --output text | sed 's|/hostedzone/||')
export SECRET_ID=superset-eks-dev/superset

chmod +x scripts/*.sh
./scripts/deploy-app.sh
```

Open:

```text
https://app.superset.atwish.org
```

Login: `admin` + `terraform output -raw superset_admin_password`

## Config (`superset_config.py`)

- Source of truth: `docker/superset_config.py`
- Loaded into the cluster as ConfigMap `superset-config`
- Mounted at `/app/pythonpath/superset_config.py`
- Secrets still come from env (`SUPERSET_SECRET_KEY`, `DATABASE_URL`, `REDIS_URL`)

Update config:

```bash
kubectl create configmap superset-config \
  -n superset \
  --from-file=superset_config.py=docker/superset_config.py \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl rollout restart deploy/superset-web deploy/superset-worker deploy/superset-beat -n superset
```

## Scaling

| Workload | Scale? | How |
|---|---|---|
| web | Yes | HPA on CPU (2–6) |
| worker | Yes | HPA on CPU (1–6) |
| beat | **No** | Always `replicas: 1` |

## Destroy

```bash
kubectl delete namespace superset --ignore-not-found
helm uninstall aws-load-balancer-controller -n kube-system --ignore-not-found
cd terraform && terraform destroy
```

## Notes

- ALB is created by the **AWS Load Balancer Controller** from the Ingress — not by Terraform directly.
- DNS A/ALIAS record is created by `scripts/deploy-app.sh` after the ALB hostname appears.
- Beat must never scale above 1.
- Pin image tags (`apache/superset:4.1.1`). Avoid `latest`.
