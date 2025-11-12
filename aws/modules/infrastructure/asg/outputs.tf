output app_asg_name {
    description = "The name of the Auto Scaling Group for the webserver cluster"
    value       = aws_autoscaling_group.app_asg.name
}

output ws_security_group {
    description = "The security group for the webserver instances"
    value       = aws_security_group.app_sg.id
}