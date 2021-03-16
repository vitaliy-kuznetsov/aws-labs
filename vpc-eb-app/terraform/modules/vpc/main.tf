locals {
    public_routes = concat(aws_route_table.nat-gw-rt[*].id,aws_route_table.nodes-rt[*].id)

}
############### VPC configuration ###############

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.standard_tags,
    map("Name", "${var.vpc_name}")
  )
}

############### Subnets configuration ###############

resource "aws_subnet" "nodes-subnets" {
  count                   = length(var.azs)
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    var.standard_tags,
    map("Name", "NODES-${var.azs[count.index]}")
  )
}

resource "aws_subnet" "nat-gw-subnets" {
  count                   = length(var.azs)
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    var.standard_tags,
    map("Name", "NAT-GW-${var.azs[count.index]}")
  )
}
resource "aws_subnet" "elb-subnets" {
  count                   = length(var.azs)
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 30)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    var.standard_tags,
    map("Name", "ELB-${var.azs[count.index]}")
  )
}

resource "aws_subnet" "rds-subnets" {
  count                   = length(var.azs)
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 40)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    var.standard_tags,
    map("Name", "RDS-${var.azs[count.index]}")
  )
}
############### IGW configuration ###############

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    var.standard_tags,
    map("Name", "IGW")
  )
}

############### NAT GW configuration ################
resource "aws_eip" "nat-ips" {
  count            = var.subnet_count
  vpc              = true
  tags = merge(
    var.standard_tags,
    map("Name", "NAT-EIP-${var.azs[count.index]}")
  )
}
resource "aws_nat_gateway" "nat-gws" {
  count = var.subnet_count
  allocation_id = aws_eip.nat-ips[count.index].id
  subnet_id     = aws_subnet.nat-gw-subnets[count.index].id
  tags = merge(
    var.standard_tags,
    map("Name", "NAT_GW-${var.azs[count.index]}")
  )
}

############ Route Tables configuration #############

resource "aws_route_table" "nodes-rt" {
  count = length(var.azs)
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.standard_tags,
    map("Name", "NODES-RT-${var.azs[count.index]}")
  )
}

resource "aws_route_table" "elb-rt" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.standard_tags,
    map("Name", "ELB-RT")
  )
}

resource "aws_route_table" "nat-gw-rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.standard_tags,
    map("Name", "NAT_RT")
  )
}

#### Routes ####
resource "aws_route" "nat-routes" {
  count = length(var.azs)
  route_table_id         = aws_route_table.nodes-rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-gws[count.index].id
  depends_on             = [aws_route_table.nodes-rt,aws_nat_gateway.nat-gws]
}

resource "aws_route" "public-routes" {
  count = length(list(aws_route_table.elb-rt,aws_route_table.nat-gw-rt))
  route_table_id         = list(aws_route_table.elb-rt,aws_route_table.nat-gw-rt)[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id         = aws_internet_gateway.main_igw.id
}

resource "aws_route_table_association" "nat-gw-rts" {
  count          = length(aws_subnet.nat-gw-subnets)
  subnet_id      = aws_subnet.nat-gw-subnets[count.index].id
  route_table_id = aws_route_table.nat-gw-rt.id
}

resource "aws_route_table_association" "elb-rts" {
  count          = length(aws_subnet.elb-subnets)
  subnet_id      = aws_subnet.elb-subnets[count.index].id
  route_table_id = aws_route_table.elb-rt.id
}

resource "aws_route_table_association" "nodes-rts" {
  count = length(var.azs)
  subnet_id      = aws_subnet.nodes-subnets[count.index].id
  route_table_id = aws_route_table.nodes-rt[count.index].id
}
