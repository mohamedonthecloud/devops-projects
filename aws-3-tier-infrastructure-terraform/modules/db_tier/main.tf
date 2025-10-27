resource "aws_db_instance" "database" {
  db_name           = "${var.environment}-mysql-db"
  allocated_storage = 20
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  multi_az          = true
  username          = var.db_username
  password          = var.db_password
  kms_key_id        = aws_kms_key.db.id
  

  db_subnet_group_name   = aws_db_subnet_group.db_tier.name
  vpc_security_group_ids = [var.db_sg]

  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "db_tier" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.db_private_subnets

  tags = local.tags
}

resource "aws_kms_key" "db" {
  description             = "An example symmetric encryption KMS key"
  enable_key_rotation     = true
  deletion_window_in_days = 20
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow administration of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Alice"
        },
        Action = [
          "kms:ReplicateKey",
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Bob"
        },
        Action = [
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext"
        ],
        Resource = "*"
      }
    ]
  })
}