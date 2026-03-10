resource "aws_security_group" "alb" {
  for_each    = toset(var.environments)
  name        = "${var.project_name}-${each.key}-alb-sg"
  description = "Allow HTTP traffic to ALB ${each.key}"
  vpc_id      = aws_vpc.cloudcore.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${each.key}-alb-sg"
    Project     = var.project_name
    Environment = each.key
  }
}

resource "aws_lb" "cloudcore" {
  for_each           = toset(var.environments)
  name               = "${var.project_name}-${each.key}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[each.key].id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name        = "${var.project_name}-${each.key}-alb"
    Project     = var.project_name
    Environment = each.key
  }
}

resource "aws_lb_target_group" "cloudcore" {
  for_each    = toset(var.environments)
  name        = "${var.project_name}-${each.key}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.cloudcore.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = {
    Name        = "${var.project_name}-${each.key}-tg"
    Project     = var.project_name
    Environment = each.key
  }
}

resource "aws_lb_listener" "cloudcore" {
  for_each          = toset(var.environments)
  load_balancer_arn = aws_lb.cloudcore[each.key].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cloudcore[each.key].arn
  }
}