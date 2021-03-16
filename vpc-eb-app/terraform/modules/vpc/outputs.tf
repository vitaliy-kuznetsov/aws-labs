
output "vpc_id" {
  value = aws_vpc.main.id
}
output "elb_subnets" {
  value = aws_subnet.elb-subnets.*.id
}

output "rds_subnets" {
  value = aws_subnet.rds-subnets.*.id
}

output "nodes_subnets" {
  value = aws_subnet.nodes-subnets.*.id
}