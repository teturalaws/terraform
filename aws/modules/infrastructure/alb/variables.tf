variable "alb_name" {
  description = "Base name for ALB and related resources"
  type        = string
}

variable "allowed_ingress_cidrs" {
  description = "CIDR blocks allowed to access ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "http_port" {
  description = "Port for ALB listener"
  type        = number
  default     = 80
}

variable "server_port" {
  description = "Port for target group backend"
  type        = number
  default     = 8080
}

variable "internal" {
  description = "Whether the ALB is internal or internet-facing"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection on ALB"
  type        = bool
  default     = false
}

# Health check variables
variable "health_check_path" {
  description = "Path for target group health check"
  type        = string
  default     = "/"
}

variable "health_check_protocol" {
  description = "Protocol for health check"
  type        = string
  default     = "HTTP"
}

variable "health_check_matcher" {
  description = "Matcher for health check status codes"
  type        = string
  default     = "200-399"
}

variable "health_check_interval" {
  description = "Interval between health checks"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Timeout for health checks"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successes for healthy status"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failures for unhealthy status"
  type        = number
  default     = 2
}
