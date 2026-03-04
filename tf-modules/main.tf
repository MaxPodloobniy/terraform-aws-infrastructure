provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  prefix         = var.prefix
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets
}

module "network_security" {
  source = "./modules/network_security"

  prefix           = var.prefix
  vpc_id           = module.network.vpc_id
  allowed_ip_range = var.allowed_ip_range
}

module "application" {
  source = "./modules/application"

  prefix        = var.prefix
  ami_id        = var.ami_id
  instance_type = var.instance_type
  subnet_ids    = module.network.public_subnet_ids
  ssh_sg_id     = module.network_security.ssh_sg_id
  http_sg_id    = module.network_security.private_http_sg_id
  lb_sg_id      = module.network_security.public_http_sg_id
}