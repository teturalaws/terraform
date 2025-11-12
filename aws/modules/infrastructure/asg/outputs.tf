output app_asg_name {
    description = "The name of the Auto Scaling Group for the webserver cluster"
    value       = aws_autoscaling_group.app_asg.name
}