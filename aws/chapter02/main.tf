provider "aws" {
    region = "us-east-2"
}
variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type       = number
    default    = 8080
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
    filter {
        name   = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

resource "aws_security_group" "example_sg" {
    name        = "example-instance-sg"
    description = "Allow HTTP traffic on port 8080"
    vpc_id      = data.aws_vpc.default.id

    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "alb_ingress" {
    name              = "allow-alb-ingress"
    description       = "Allow inbound traffic to ALB on port 80"
    vpc_id      = data.aws_vpc.default.id

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
}

# Create an Application Load Balancer+
resource "aws_lb" "example_alb" {
    name               = "example-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb_ingress.id]
    subnets            = data.aws_subnets.default.ids

    enable_deletion_protection = false

    tags = {
        Name = "example-alb"
    }
}

resource "aws_lb_listener" "example_listener" {
    load_balancer_arn = aws_lb.example_alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.example_tg.arn
    }
}

resource "aws_lb_target_group" "example_tg" {
    name     = "example-tg"
    port     = var.server_port
    protocol = "HTTP"
    vpc_id   = data.aws_vpc.default.id

    health_check {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200-399"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }

    tags = {
        Name = "example-tg"
    }
}

resource "aws_launch_template" "example" {
    name_prefix   = "example-launch-template-"
    image_id      = "ami-0c55b159cbfafe1f0" # Ubuntu Server 22.04 LTS (us-east-2)
    instance_type = "t2.micro"

    user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "Hello, World!" > index.html
    nohup busybox httpd -f -p ${var.server_port} &
    EOF
    )

    vpc_security_group_ids = [aws_security_group.example_sg.id]

    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "ExampleInstance"
        }
    }
}

resource "aws_autoscaling_group" "example_asg" {
    desired_capacity     = 1
    max_size             = 2
    min_size             = 1
    vpc_zone_identifier  = data.aws_subnets.default.ids
    target_group_arns    = [aws_lb_target_group.example_tg.arn]
    health_check_type    = "ELB"
    launch_template {
        id      = aws_launch_template.example.id
        version = "$Latest"
    }

    tag {
        key                 = "Name"
        value               = "ExampleInstance"
        propagate_at_launch = true
    }

    lifecycle {
        create_before_destroy = true
    }
}
output alb_dns_name {
    description = "The DNS name of the Application Load Balancer"
    value       = aws_lb.example_alb.dns_name
}