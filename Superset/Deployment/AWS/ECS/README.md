# Deploy Apache Superset on AWS ECS (Fargate)

Simple Terraform setup using the ready-made `apache/superset` image.
No ECR needed.

## Architecture

```
Internet
   │
   ▼
ALB (port 80)
   │
   ▼
ECS Fargate
├── web     (scalable)
├── worker  (scalable)
└── beat    (always 1)
   │
   ├── RDS PostgreSQL   (metadata DB)
   └── ElastiCache Redis (cache + Celery)
```

Secrets live in **AWS Secrets Manager**.
Config file lives in `docker/superset_config.py` and is injected at container start.

## What gets created

| Resource | Purpose |
|---|---|
| VPC + subnets + security groups | Networking |
| ALB | Public entry point |
| RDS PostgreSQL | Superset metadata |
| ElastiCache Redis | Cache + Celery broker |
| Secrets Manager | DB URL, secret key, admin password |
| ECS cluster + 3 services | web / worker / beat |

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.5
- Permissions to create VPC, ECS, RDS, ElastiCache, ALB, IAM, Secrets Manager

## Deploy

```bash
cd terraform

terraform init
terraform plan
terraform apply
```

After apply:

```bash
# Get the URL
terraform output alb_url

# Get admin password
terraform output -raw superset_admin_password
```

Login with username `admin` and that password.

## Scaling

| Service | Scale? | How |
|---|---|---|
| web | Yes | Auto scales on CPU (min = `web_desired_count`, max = 6) |
| worker | Yes | Auto scales on CPU (min = `worker_desired_count`, max = 6) |
| beat | **No** | Always keep at 1 (duplicate beat = duplicate scheduled jobs) |

Change counts in `variables.tf`:

```hcl
variable "web_desired_count"    { default = 2 }
variable "worker_desired_count" { default = 1 }
variable "beat_desired_count"   { default = 1 }  # do not raise this
```

## Config

Edit `docker/superset_config.py`, then re-apply Terraform and force a new ECS deployment:

```bash
terraform apply
aws ecs update-service --cluster <cluster> --service <web-service> --force-new-deployment
```

## Destroy

```bash
terraform destroy
```

## Notes

- ECS tasks run in **public subnets with public IPs** so they can pull from Docker Hub without a NAT Gateway (cheaper for demos).
- For production, move tasks to private subnets + NAT Gateway.
- Add HTTPS later with an ACM certificate on the ALB listener.
- Pin the image version (already done: `apache/superset:4.1.1`). Avoid `latest`.
