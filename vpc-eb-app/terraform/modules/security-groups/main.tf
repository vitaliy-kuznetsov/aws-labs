resource "aws_security_group" "nodes-sg" {
  name   = "EC2-NODES-SG"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "elb-sg" {
  name   = "ELB-SG"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
  var.standard_tags,
  map("Name", "ELB-SG")
  )

}

resource "aws_security_group" "rds-sg" {
  name   = "RDS-SG"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
  var.standard_tags,
  map("Name", "RDS-SG")
  )

}

resource "aws_security_group_rule" "nodes-ingress" {
  type              = "ingress"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = "tcp"
  source_security_group_id = aws_security_group.elb-sg.id
  security_group_id = aws_security_group.nodes-sg.id
}

resource "aws_security_group_rule" "rds-ingress" {
  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  source_security_group_id = aws_security_group.nodes-sg.id
  security_group_id = aws_security_group.rds-sg.id
}

resource "aws_security_group_rule" "elb-ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.elb-sg.id
}