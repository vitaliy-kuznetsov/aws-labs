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
    map("Name", "EKS-VPC")
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.secondary_cidr
}
############### Subnets configuration ###############

resource "aws_subnet" "nodes-subnets" {
  count                   = length(var.azs)
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    var.standard_tags,
    var.eks_tags,
    map("Name", "NODES-${var.azs[count.index]}")
  )
}
resource "aws_subnet" "nat-gw-subnets" {
  count                   = length(var.azs)
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    var.standard_tags,
    map("Name", "NAT-GW-${var.azs[count.index]}")
  )
}


resource "aws_subnet" "fe-pods-subnets" {
  count                   = var.subnet_count
  cidr_block              = cidrsubnet(var.secondary_cidr, 4, count.index)
  vpc_id                  = aws_vpc_ipv4_cidr_block_association.secondary_cidr.vpc_id
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    var.standard_tags,
    map("Name", "FE-PODS-${var.azs[count.index]}")
  )

}

resource "aws_subnet" "be-pods-subnets" {
  count                   = var.subnet_count
  cidr_block              = cidrsubnet(var.secondary_cidr, 4, count.index + 2)
  vpc_id                  = aws_vpc_ipv4_cidr_block_association.secondary_cidr.vpc_id
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    var.standard_tags,
    map("Name", "BE-PODS-${var.azs[count.index]}")
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
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.standard_tags,
    map("Name", "nodes-rt")
  )
}
resource "aws_route_table" "nat-gw-rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.standard_tags,
    map("Name", "NAT_RT")
  )
}

resource "aws_route_table" "pods-rt" {
  vpc_id = aws_vpc.main.id
  count = var.subnet_count
  tags = merge(
    var.standard_tags,
    map("Name", "PODS-RT-${var.azs[count.index]}")
  )
}

resource "aws_route" "pods-a" {
  route_table_id         = aws_route_table.pods-rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = aws_nat_gateway.nat-gws[0].id
  depends_on             = [aws_route_table.pods-rt,aws_nat_gateway.nat-gws]
}

resource "aws_route" "pods-b" {
  route_table_id         = aws_route_table.pods-rt[1].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = aws_nat_gateway.nat-gws[1].id
  depends_on             = [aws_route_table.pods-rt,aws_nat_gateway.nat-gws]
}

resource "aws_route_table_association" "nodes-rt-assoc" {
  count = length(aws_subnet.nodes-subnets)

  route_table_id = aws_route_table.nodes-rt.id
  subnet_id      = element(aws_subnet.nodes-subnets.*.id, count.index)
}


resource "aws_route_table_association" "nat-rt-assoc" {
  count = length(aws_subnet.nat-gw-subnets)

  route_table_id = aws_route_table.nat-gw-rt.id
  subnet_id      = element(aws_subnet.nat-gw-subnets.*.id, count.index)
}

resource "aws_route_table_association" "fe-pods-rt-assoc" {
  count = length(aws_subnet.fe-pods-subnets)
  route_table_id = aws_route_table.pods-rt[count.index].id
  subnet_id      = aws_subnet.fe-pods-subnets[count.index].id
}

resource "aws_route_table_association" "be-pods-rt-assoc" {
  count = length(aws_subnet.be-pods-subnets)
  route_table_id = aws_route_table.pods-rt[count.index].id
  subnet_id      = aws_subnet.be-pods-subnets[count.index].id
}

resource "aws_route" "igw-route" {
  count = length(local.public_routes)
  route_table_id         = local.public_routes[count.index]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
  depends_on             = [aws_route_table.nodes-rt]
}

