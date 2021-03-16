
output "nodes-sg" {
  value = aws_security_group.nodes-sg.id
}

output "elb-sg" {
  value = aws_security_group.elb-sg.id
}

output "rds-sg" {
  value = aws_security_group.rds-sg.id
}