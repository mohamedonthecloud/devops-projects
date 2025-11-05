resource "aws_db_instance" "database" {
  db_name           = "${var.environment}mysqldb"
  allocated_storage = 20
  engine            = "mysql"
  instance_class    = var.instance_class
  multi_az          = true
  username          = var.db_username
  password          = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_tier.name
  vpc_security_group_ids = [var.db_sg]

  storage_encrypted = true
  kms_key_id        = aws_kms_key.db.arn
  
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "db_tier" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.db_private_subnets

  tags = local.tags
}

resource "aws_kms_key" "db" {
  description             = "KMS key for ${var.environment} RDS database encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_rds.json

  tags = {
    Name        = "${var.environment}-rds-kms-key"
    Environment = var.environment
  }
}