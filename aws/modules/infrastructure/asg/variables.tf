variable "cluster_name" {
  description = "Name of the cluster, used in resource naming"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the ASG"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for instances"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Ubuntu 22.04 LTS us-east-2
}

variable "db_address" {
  description = "Database endpoint for application"
  type        = string
}

variable "db_port" {
  description = "Database port for application"
  type        = number
  default     = 3306
}

variable "server_port" {
  description = "Port the application will listen on"
  type        = number
  default     = 8080
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "subnets" {
  description = "List of subnet IDs for the ASG"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the target group for the ASG"
  type        = string
}