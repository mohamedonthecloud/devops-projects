/* resource "aws_instance" "app_server_private" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.private_subnets[count.index]

  tags = {
    Name = "${var.environment}-app-tier-private-${count.index + 1}"
  }
} */

/* resource "aws_lb_target_group_attachment" "web_instances" {
  # covert a list of instance objects to a map with instance ID as the key, and an instance
  # object as the value.
  for_each = {
    for k, v in aws_instance.app_server_private :
    k => v
  }

  target_group_arn = aws_lb_target_group.app_instances.arn
  target_id        = each.value.id
  port             = 80
} */

resource "aws_lb_listener" "app_instances" {
  load_balancer_arn = aws_lb.private_facing.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_instances.arn
  }
} 


resource "aws_lb" "private_facing" {
  name               = "${var.environment}-load-balancer-private"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.private_lb_sg]
  subnets            = var.private_subnets

  tags = local.tags
} 

resource "aws_launch_template" "private" {
  name_prefix            = "private"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.private_sg]

  tag_specifications {
    resource_type = "instance"
    tags = local.tags
  }
}

resource "aws_autoscaling_group" "public" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = var.private_subnets
  target_group_arns   = [aws_lb_target_group.app_instances.arn]

  launch_template {
    id      = aws_launch_template.private.id
    version = "$Latest"
  }
}

resource "aws_lb_target_group" "app_instances" {
  name     = "${var.environment}-app-instance-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}