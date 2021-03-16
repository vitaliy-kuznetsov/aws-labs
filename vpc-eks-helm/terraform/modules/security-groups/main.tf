resource "aws_security_group" "nodes-sg" {
  name   = "EKS-NODES-SG"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
  var.standard_tags,
  var.eks_sg_tags,
  map("Name", "EKS-NODES-SG")
  )

}

resource "aws_security_group" "fe-pods-sg" {
  name   = "FE_PODS_SG"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
  var.standard_tags,
  map("Name", "FE_PODS_SG")
  )
}

resource "aws_security_group" "be-pods-sg" {
  name   = "BE_PODS_SG"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
  var.standard_tags,
  map("Name", "BE_PODS_SG")
  )
}
resource "aws_security_group_rule" "eks-ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = aws_security_group.nodes-sg.id
  security_group_id = var.cluster_sg
}

resource "aws_security_group_rule" "elb-ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  source_security_group_id = aws_security_group.lb-sg.id
  security_group_id = aws_security_group.nodes-sg.id
}
resource "aws_security_group_rule" "eks-logs-ingress" {
  type              = "ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  source_security_group_id = var.cluster_sg
  security_group_id = aws_security_group.nodes-sg.id
}

resource "aws_security_group" "lb-sg" {
  name   = "EKS-LB-SG"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
  var.standard_tags,
  var.eks_sg_tags,
  map("Name", "EKS-ELB-SG")
  )

}
