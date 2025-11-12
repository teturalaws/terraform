provider "aws" {
  region = var.aws_region
}

module "webserver-cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name     = var.cluster_name
  instance_type    = var.instance_type
  desired_capacity = var.desired_capacity
  vpc_id           = var.vpc_id
  subnet_ids       = var.subnet_ids
}
