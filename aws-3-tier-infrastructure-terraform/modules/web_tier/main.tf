/* resource "aws_instance" "web_server_public" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.public_subnets[count.index]

  tags = {
    Name = "${var.environment}-app-tier-public-${count.index + 1}"
  }
}

resource "aws_lb_target_group_attachment" "web_instances" {
  # covert a list of instance objects to a map with instance ID as the key, and an instance
  # object as the value.
  for_each = {
    for k, v in aws_instance.web_server_public :
    k => v
  }

  target_group_arn = aws_lb_target_group.web_instances.arn
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb_listener" "web_instances" {
  load_balancer_arn = aws_lb.public_facing.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_instances.arn
  }
} */

resource "aws_lb_target_group" "web_instances" {
  name     = "${var.environment}-web-instance-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb" "public_facing" {
  name               = "${var.environment}-load-balancer-web-facing"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_lb_sg]
  subnets            = var.public_subnets

  tags = local.tags
}

resource "aws_launch_template" "public" {
  name_prefix            = "public"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.public_sg]

  tag_specifications {
    resource_type = "instance"
    tags = local.tags
  }
}

resource "aws_autoscaling_group" "public" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = var.public_subnets
  target_group_arns   = [aws_lb_target_group.web_instances.arn]

  launch_template {
    id      = aws_launch_template.public.id
    version = "$Latest"
  }
}