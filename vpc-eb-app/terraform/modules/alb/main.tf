resource "aws_lb" "test" {
  name               = var.alb_name
  load_balancer_type = "application"
  security_groups    = [var.lb_sg]
  subnets            = var.lb_subnets

  tags = var.tags
}