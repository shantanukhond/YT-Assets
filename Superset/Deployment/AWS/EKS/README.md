# Deploy Apache Superset on AWS EKS

Same architecture as the ECS guide, but workloads run on **Kubernetes (EKS)**.
Uses the official `apache/superset:6.0.0` image and the same bootstrap script as
`docker-compose-image-tag.yml` (with `TAG=6.0.0`) — no ECR needed.

## Architecture

![Superset AWS EKS Deployment Architecture](./Superset%20AWS%20EKS%20Deployment%20Architecture.png)

```
Internet
   │  app.superset.atwish.org (Cloudflare DNS + ACM)
   ▼
┌──────────────── AWS Cloud ───────────────────────┐
│  ACM · Secrets Manager · CloudWatch              │
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
| Bootstrap script | env base64 at start | ConfigMap mounted as executable file (`defaultMode: 0755`) |
| Secrets | ECS secrets injection | K8s Secret (from Secrets Manager) |
| Scaling | App Auto Scaling | HPA (web + worker); beat = 1 |

## Prerequisites

- AWS CLI, Terraform >= 1.5, kubectl, helm
- Domain DNS in Cloudflare (or any DNS provider)
- Permissions for EKS, VPC, RDS, ElastiCache, IAM, ACM

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
terraform output acm_validation_records
terraform output -raw superset_admin_password
```

## 2) Deploy AWS LB Controller + Superset

```bash
cd ..

export AWS_REGION=ap-south-1
export CLUSTER_NAME=$(cd terraform && terraform output -raw cluster_name)
export ALB_CONTROLLER_ROLE_ARN=$(cd terraform && terraform output -raw alb_controller_role_arn)
export CERTIFICATE_ARN=$(cd terraform && terraform output -raw certificate_arn)
export SECRET_ID=superset-eks-dev/superset

chmod +x scripts/*.sh
./scripts/deploy-app.sh
```

The script prints the ALB hostname. Add in **Cloudflare** (DNS only / grey cloud):

| Type | Name | Target | Proxy |
|---|---|---|---|
| CNAME | `app.superset` | ALB hostname from script | Off |
| CNAME | *(ACM validation from `terraform output acm_validation_records`)* | *(value)* | Off |

Then enable HTTPS cert validation if needed and open:

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

## Bootstrap script (`docker-bootstrap.sh`)

- Source of truth: `docker/docker-bootstrap.sh` (copied from `apache/superset` tag `6.0.0`)
- Loaded into the cluster as ConfigMap `superset-bootstrap`
- Mounted at `/app/docker/docker-bootstrap.sh` with `defaultMode: 0755` (executable despite the read-only ConfigMap mount)
- Containers run as `runAsUser: 0` so the script's `pip install -e .[postgres]` step (gated on `whoami = root`) can run
- web runs `docker-bootstrap.sh app-gunicorn`, worker runs `docker-bootstrap.sh worker`, beat runs `docker-bootstrap.sh beat` — same pattern as ECS

Update bootstrap script:

```bash
kubectl create configmap superset-bootstrap \
  -n superset \
  --from-file=docker-bootstrap.sh=docker/docker-bootstrap.sh \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl rollout restart deploy/superset-web deploy/superset-worker deploy/superset-beat -n superset
```

## Test locally before deploying

Same image + bootstrap script, run against local Postgres/Redis instead of RDS/ElastiCache:

```bash
cd docker
docker compose -f docker-compose.local.yml up -d
open http://localhost:8088   # admin / admin
docker compose -f docker-compose.local.yml down -v
```

## Scaling

| Workload | Scale? | How |
|---|---|---|
| web | Yes | HPA on CPU (1–6) |
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
- DNS is managed in **Cloudflare** (CNAME to ALB). No Route53 required.
- Beat must never scale above 1.
- Pin image tags (`apache/superset:6.0.0`). Avoid `latest`.
