resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_db_subnet_group" "lab-sn-group" {
  name       = "main"
  subnet_ids = var.db_subnets

  tags = {
    Name = "LAB_SN_GROUP"
  }
}

resource "aws_db_instance" "lab-db" {
  allocated_storage    = var.db_storage
  engine               = var.db_engine
  instance_class       = var.db_instance
  name                 = var.db_name
  username             = var.db_username
  vpc_security_group_ids = [var.db_sg]
  db_subnet_group_name = aws_db_subnet_group.lab-sn-group.name
  password             = random_password.db_password.result
  skip_final_snapshot  = true
  publicly_accessible = false
  identifier = "lab-db"
}