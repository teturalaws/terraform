locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

# Security group
resource "aws_security_group" "app_sg" {
  name        = "${var.cluster_name}-instance-sg"
  description = "Allow HTTP traffic on port ${local.http_port}"

  tags = {
    Name = "${var.cluster_name}-instance-sg"
  }
}

# Ingress rule
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  from_port         = local.http_port
  to_port           = local.http_port
  protocol          = local.tcp_protocol
  security_group_id = aws_security_group.app_sg.id
  cidr_blocks       = local.all_ips
}

# Egress rule
resource "aws_security_group_rule" "allow_http_outbound" {
  type              = "egress"
  from_port         = local.any_port
  to_port           = local.any_port
  protocol          = local.any_protocol
  security_group_id = aws_security_group.app_sg.id
  cidr_blocks       = local.all_ips
}

# Launch template
resource "aws_launch_template" "app" {
  name_prefix   = "${var.cluster_name}-launch-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    db_address  = var.db_address
    db_port     = var.db_port
    server_port = var.server_port
  }))

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.subnets
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
