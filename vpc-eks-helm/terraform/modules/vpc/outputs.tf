
output "vpc_id" {
  value = aws_vpc.main.id
}
output "nodes-subnets" {
  value = aws_subnet.nodes-subnets[*].id
}

output "fe-pods-subnets" {
  value = aws_subnet.fe-pods-subnets[*].id
}

output "be-pods-subnets" {
  value = aws_subnet.be-pods-subnets[*].id
}
