
output "nodes-sg" {
  value = aws_security_group.nodes-sg.id
}
output "fe-pods-sg" {
  value = aws_security_group.fe-pods-sg.id
}

output "be-pods-sg" {
  value = aws_security_group.be-pods-sg.id
}
output "lb-sg" {
  value = aws_security_group.lb-sg.id
}
