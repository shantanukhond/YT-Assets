# Deploy Apache Superset on AWS ECS (Fargate)

Simple Terraform setup using the ready-made `apache/superset` image.
No ECR needed.

## Architecture

![Superset AWS Deployment Architecture](./Superset%20AWS%20Deployment%20Architecture.png)


| Subnet | What lives there | Internet |
|---|---|---|
| Public | ALB, NAT | Yes (IGW) |
| Private app | ECS web / worker / beat | Outbound only via NAT |
| Private data | RDS + Redis | None |

Secrets live in **AWS Secrets Manager**.
Config file lives in `docker/superset_config.py` and is injected at container start.

## What gets created

| Resource | Purpose |
|---|---|
| VPC + 6 subnets (2 public, 2 app, 2 data) | Networking across 2 AZs |
| NAT Gateway | Private ECS can pull Docker Hub images |
| ALB | Public entry point |
| RDS PostgreSQL | Superset metadata |
| ElastiCache Redis | Cache + Celery broker |
| Secrets Manager | DB URL, secret key, admin password |
| ECS cluster + 3 services | web / worker / beat |

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.5
- Permissions to create VPC, ECS, RDS, ElastiCache, ALB, IAM, Secrets Manager, NAT Gateway

## Deploy

```bash
cd terraform

terraform init
terraform plan
terraform apply
```

After apply:

```bash
# ALB hostname (use this as Cloudflare CNAME target)
terraform output alb_dns_name

# Cloudflare records to add
terraform output cloudflare_app_cname
terraform output acm_validation_records

# Get admin password
terraform output -raw superset_admin_password
```

Login with username `admin` and that password.

## Custom domain (Cloudflare)

DNS is managed in **Cloudflare** (no Route53).

### Step 1 — First apply (HTTP works)

```bash
terraform apply
```

### Step 2 — Add Cloudflare DNS records (DNS only / grey cloud)

**App hostname:**

| Type | Name | Target | Proxy |
|---|---|---|---|
| CNAME | `app.superset` | value of `terraform output -raw alb_dns_name` | Off (grey) |

**ACM validation** (from `terraform output acm_validation_records`):

| Type | Name | Target | Proxy |
|---|---|---|---|
| CNAME | *(from output)* | *(from output)* | Off (grey) |

### Step 3 — Enable HTTPS

```bash
terraform apply -var='enable_https=true'
```

This waits for ACM to become Issued, then attaches HTTPS :443 and redirects HTTP → HTTPS.

Open: `https://app.superset.atwish.org`


## Scaling

| Service | Scale? | How |
|---|---|---|
| web | Yes | Auto scales on CPU (min = `web_desired_count`, max = 6) |
| worker | Yes | Auto scales on CPU (min = `worker_desired_count`, max = 6) |
| beat | **No** | Always keep at 1 (duplicate beat = duplicate scheduled jobs) |

Change counts in `variables.tf`:

```hcl
variable "web_desired_count"    { default = 1 }
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

- ECS runs in **private-app** subnets (no public IP). Outbound traffic goes through **NAT Gateway**.
- RDS and Redis run in **private-data** subnets with **no internet route**.
- NAT Gateway has a monthly cost — expected for this production-style layout.
- Custom domain uses **ACM + Cloudflare DNS** (no Route53).
- Pin the image version (already done: `apache/superset:4.1.1`). Avoid `latest`.
