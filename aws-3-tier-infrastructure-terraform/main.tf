module "main_vpc" {
  source                   = "./modules/vpc"
  environment              = var.environment
  availability_zones       = var.availability_zones
  vpc_cidr                 = var.vpc_cidr
  app_private_subnet_cidrs = var.app_private_subnet_cidrs
  db_private_subnet_cidrs  = var.db_private_subnet_cidrs
  public_subnet_cidrs      = var.public_subnet_cidrs
}