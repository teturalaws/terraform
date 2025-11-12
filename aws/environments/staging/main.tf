provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

# Get all subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

terraform {
  backend "s3" {
    bucket         = "mytfstate-teturalaws"        # Change to your unique bucket name
    key            = "staging/terraform.tfstate" # Change to your desired state file path
    region         = "us-east-2"
    dynamodb_table = "terraform-locks-teturalaws"   # Change to your unique table name
    encrypt        = true
  }
}

module "mysql" {
  source = "../../modules/data-store/mysql"

  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = var.db_instance_class
  db_allocated_storage  = var.db_allocated_storage
}

module "alb" {
  source = "../../modules/infrastructure/alb"
  subnets = data.aws_subnets.default.ids
  vpc_id  = data.aws_vpc.default.id
  alb_name            = var.alb_name
  server_port         = var.server_port
}

module "autoscaling" {
  source = "../../modules/infrastructure/asg"

  cluster_name = var.cluster_name
  instance_type = var.instance_type
  desired_capacity = var.desired_capacity
  target_group_arn = module.alb.target_group_arn
  subnets = data.aws_subnets.default.ids
  db_address = module.mysql.address
  db_port    = module.mysql.port
}

resource "aws_security_group_rule" "allow_testing_inbound"{
  type = "ingress"
  security_group_id = module.autoscaling.ws_security_group
  from_port = 12345
  to_port = 12345
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"
  autoscaling_group_name = module.autoscaling.app_asg_name
}
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
  autoscaling_group_name = module.autoscaling.app_asg_name
}

