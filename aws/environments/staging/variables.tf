variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-2"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI in us-east-2
}

#Mysql variables
variable "db_name" {
  description = "Name of the MySQL database"
  type        = string
}

variable "db_username" {
  description = "Username for the database"
  type        = string
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Instance class for the database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Storage (in GB) for the database"
  type        = number
  default     = 20
}

variable "alb_name" {
  description = "Name of the ALB, used in resource names"
  type        = string
}

#ASG variables
variable "server_port" {
  description = "Port the application will listen on"
  type        = number
  default     = 8080
}
variable "cluster_name" {
  description = "Name of the cluster, used in resource naming"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the ASG"
  type        = string
  default     = "t3.micro"
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 1
}