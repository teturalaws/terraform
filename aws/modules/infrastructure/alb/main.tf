# Security group
resource "aws_security_group" "alb" {
  name        = "${var.alb_name}-alb"
  description = "ALB Security Group"

  tags = {
    Name = "${var.alb_name}-alb"
  }
}

# Ingress rule
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = var.http_port
  to_port           = var.http_port
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = var.allowed_ingress_cidrs
}

# Egress rule
resource "aws_security_group_rule" "alb_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Target group
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.alb_name}-tg"
  vpc_id   = var.vpc_id
  target_type = "instance"
  port     = var.server_port
  protocol = "HTTP"

  health_check {
    path                = var.health_check_path
    protocol            = var.health_check_protocol
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  tags = {
    Name = "${var.alb_name}-tg"
  }
}

# Load balancer
resource "aws_lb" "app_alb" {
  name                       = "${var.alb_name}-alb"
  internal                   = var.internal
  load_balancer_type         = "application"
  subnets                    = var.subnets
  security_groups            = [aws_security_group.alb.id]
  enable_deletion_protection = var.deletion_protection

  tags = {
    Name = "${var.alb_name}-alb"
  }
}

# Listener
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
