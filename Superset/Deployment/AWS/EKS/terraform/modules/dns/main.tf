locals {
  name = "${var.project_name}-${var.environment}"
}

# ACM cert — validate via Cloudflare DNS (no Route53)
resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.name}-cert"
  }
}

# Optional: wait for Cloudflare validation when enable_https=true
resource "aws_acm_certificate_validation" "main" {
  count = var.enable_https ? 1 : 0

  certificate_arn = aws_acm_certificate.main.arn

  timeouts {
    create = "45m"
  }
}
