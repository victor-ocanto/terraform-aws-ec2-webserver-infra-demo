# Create Application Load Balancer
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb-sg]  # alb security group
  subnets            = [var.pub-subnet-a-id, var.pub-subnet-b-id]

  enable_deletion_protection = false

  tags = {
    Name = "web-alb"
  }
}

# Create Target Group for Web Server
resource "aws_lb_target_group" "web_target_group" {
  name        = "web-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc-id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "web-target-group"
  }
}

resource "aws_lb_target_group_attachment" "web_targets" {
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = var.web-server-id
  port             = 80
}


# Create Listener for ALB to forward HTTP traffic
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}
