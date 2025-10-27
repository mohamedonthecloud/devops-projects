/* resource "aws_instance" "app_server_public" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "${var.environment}-app-tier-public-${count.index + 1}"
  }
}

resource "aws_instance" "app_server_private" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_subnets[count.index].id

  tags = {
    Name = "${var.environment}-app-tier-private-${count.index + 1}"
  }
} */

resource "aws_lb" "private_facing" {
  name               = "${var.environment}-load-balancer-private"
  internal           = false
  load_balancer_type = "application"
  security_groups    = module.security.aws_security_group.private_lb.id
  subnets            = module.vpc.aws_subnet.private.id

  enable_deletion_protection = true

  tags = local.tags
} 

resource "aws_launch_template" "private" {
  name_prefix            = "private"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.security.aws_security_group.app_tier_instances.id]

  tag_specifications {
    resource_type = "instance"
    tags = local.tags
  }
}

resource "aws_autoscaling_group" "public" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = module.vpc.aws_subnet.private.id
  target_group_arns   = aws_lb.private_facing

  launch_template {
    id      = aws_launch_template.private.id
    version = "$Latest"
  }
}