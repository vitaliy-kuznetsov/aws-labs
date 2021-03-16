output "fe-lt" {
    value = { id = aws_launch_template.fe-nodegroup.id, default_version = aws_launch_template.fe-nodegroup.latest_version }
}