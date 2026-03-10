resource "aws_security_group" "ecs" {
  for_each    = toset(var.environments)
  name        = "${var.project_name}-${each.key}-ecs-sg"
  description = "Allow traffic from ALB to ECS ${each.key}"
  vpc_id      = aws_vpc.cloudcore.id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb[each.key].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${each.key}-ecs-sg"
    Project     = var.project_name
    Environment = each.key
  }
}

resource "aws_ecs_cluster" "cloudcore" {
  for_each = toset(var.environments)
  name     = "${var.project_name}-${each.key}-cluster"

  tags = {
    Name        = "${var.project_name}-${each.key}-cluster"
    Project     = var.project_name
    Environment = each.key
  }
}

resource "aws_cloudwatch_log_group" "cloudcore" {
  for_each          = toset(var.environments)
  name              = "/ecs/${var.project_name}-${each.key}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-${each.key}-logs"
    Project     = var.project_name
    Environment = each.key
  }
}

resource "aws_ecs_task_definition" "cloudcore" {
  for_each                 = toset(var.environments)
  family                   = "${var.project_name}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "${var.project_name}-${each.key}"
    image     = "${aws_ecr_repository.cloudcore.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.project_name}-${each.key}"
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  tags = {
    Name        = "${var.project_name}-${each.key}-task"
    Project     = var.project_name
    Environment = each.key
  }
}

resource "aws_ecs_service" "cloudcore" {
  for_each        = toset(var.environments)
  name            = "${var.project_name}-${each.key}-service"
  cluster         = aws_ecs_cluster.cloudcore[each.key].id
  task_definition = aws_ecs_task_definition.cloudcore[each.key].arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs[each.key].id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.cloudcore[each.key].arn
    container_name   = "${var.project_name}-${each.key}"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.cloudcore]

  tags = {
    Name        = "${var.project_name}-${each.key}-service"
    Project     = var.project_name
    Environment = each.key
  }
}