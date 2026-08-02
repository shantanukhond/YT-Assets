locals {
  name = "${var.project_name}-${var.environment}"

  # Encode config file so we can write it at container start (no custom image/ECR needed)
  config_b64 = filebase64("${path.module}/../../../docker/superset_config.py")

  common_environment = [
    {
      name  = "SUPERSET_CONFIG_PATH"
      value = "/tmp/superset_config.py"
    },
    {
      name  = "SUPERSET_CONFIG_B64"
      value = local.config_b64
    },
    {
      name  = "SUPERSET_ADMIN_USERNAME"
      value = var.superset_admin_username
    },
    {
      name  = "SUPERSET_ADMIN_EMAIL"
      value = var.superset_admin_email
    }
  ]

  common_secrets = [
    {
      name      = "SUPERSET_SECRET_KEY"
      valueFrom = "${var.secret_arn}:SUPERSET_SECRET_KEY::"
    },
    {
      name      = "DATABASE_URL"
      valueFrom = "${var.secret_arn}:DATABASE_URL::"
    },
    {
      name      = "REDIS_URL"
      valueFrom = "${var.secret_arn}:REDIS_URL::"
    },
    {
      name      = "SUPERSET_ADMIN_PASSWORD"
      valueFrom = "${var.secret_arn}:SUPERSET_ADMIN_PASSWORD::"
    }
  ]

  write_config = "echo \"$SUPERSET_CONFIG_B64\" | base64 -d > /tmp/superset_config.py"
}

resource "aws_cloudwatch_log_group" "superset" {
  name              = "/ecs/${local.name}"
  retention_in_days = 14
}

resource "aws_ecs_cluster" "main" {
  name = "${local.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${local.name}-cluster"
  }
}

# IAM — task execution role (pull image, read secrets, write logs)
resource "aws_iam_role" "ecs_execution" {
  name = "${local.name}-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_execution_secrets" {
  name = "${local.name}-ecs-execution-secrets"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [var.secret_arn]
    }]
  })
}

resource "aws_iam_role" "ecs_task" {
  name = "${local.name}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

# ---------- WEB ----------
resource "aws_ecs_task_definition" "web" {
  family                   = "${local.name}-web"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "superset-web"
    image     = var.superset_image
    essential = true

    portMappings = [{
      containerPort = 8088
      protocol      = "tcp"
    }]

    environment = local.common_environment
    secrets     = local.common_secrets

    command = [
      "/bin/sh",
      "-c",
      "${local.write_config} && superset db upgrade && (superset fab create-admin --username \"$SUPERSET_ADMIN_USERNAME\" --firstname Admin --lastname User --email \"$SUPERSET_ADMIN_EMAIL\" --password \"$SUPERSET_ADMIN_PASSWORD\" || true) && superset init && /usr/bin/run-server.sh"
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.superset.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "web"
      }
    }
  }])
}

resource "aws_ecs_service" "web" {
  name            = "${local.name}-web"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = var.web_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "superset-web"
    container_port   = 8088
  }

  depends_on = [aws_iam_role_policy.ecs_execution_secrets]
}

# ---------- WORKER ----------
resource "aws_ecs_task_definition" "worker" {
  family                   = "${local.name}-worker"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "superset-worker"
    image     = var.superset_image
    essential = true

    environment = local.common_environment
    secrets     = local.common_secrets

    command = [
      "/bin/sh",
      "-c",
      "${local.write_config} && celery --app=superset.tasks.celery_app:app worker --pool=prefork -O fair -c 2 --loglevel=INFO"
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.superset.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "worker"
      }
    }
  }])
}

resource "aws_ecs_service" "worker" {
  name            = "${local.name}-worker"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = var.worker_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }
}

# ---------- BEAT (always desired_count = 1) ----------
resource "aws_ecs_task_definition" "beat" {
  family                   = "${local.name}-beat"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "superset-beat"
    image     = var.superset_image
    essential = true

    environment = local.common_environment
    secrets     = local.common_secrets

    command = [
      "/bin/sh",
      "-c",
      "${local.write_config} && celery --app=superset.tasks.celery_app:app beat --loglevel=INFO"
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.superset.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "beat"
      }
    }
  }])
}

resource "aws_ecs_service" "beat" {
  name            = "${local.name}-beat"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.beat.arn
  desired_count   = var.beat_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }
}

# ---------- Auto Scaling: WEB ----------
resource "aws_appautoscaling_target" "web" {
  max_capacity       = 6
  min_capacity       = var.web_desired_count
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.web.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "web_cpu" {
  name               = "${local.name}-web-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.web.resource_id
  scalable_dimension = aws_appautoscaling_target.web.scalable_dimension
  service_namespace  = aws_appautoscaling_target.web.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

# ---------- Auto Scaling: WORKER ----------
resource "aws_appautoscaling_target" "worker" {
  max_capacity       = 6
  min_capacity       = var.worker_desired_count
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "worker_cpu" {
  name               = "${local.name}-worker-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.worker.resource_id
  scalable_dimension = aws_appautoscaling_target.worker.scalable_dimension
  service_namespace  = aws_appautoscaling_target.worker.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

# No autoscaling for beat — keep exactly 1
