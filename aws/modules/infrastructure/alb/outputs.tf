output alb_dns_name {
    description = "The DNS name of the Application Load Balancer"
    value       = aws_lb.app_alb.dns_name
}

output "alb_security_group_id" {
    value = aws_security_group.alb.id
    description = "The ID of the Security Group attached to the load balancer"
}

output "target_group_arn" {
    description = "The ARN of the Application Load Balancer"
    value       = aws_lb_target_group.app_tg.arn
}