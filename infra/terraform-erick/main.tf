terraform {
  backend "s3" {
    bucket = "mi-terraform-state-erick"
    key    = "infra/terraform-erick/terraform.tfstate"
    region = "us-east-2"

  }
}

module "network" {
  source             = "./modules/network"
  app_name           = var.app_name
  vpc_cidr           = var.vpc_cidr
  app_subnet_cidr    = var.app_subnet_cidr
  availability_zones = var.availability_zones
}


module "ecr" {
  source      = "./modules/ecr"
  app_name    = var.app_name
  environment = var.environment
}

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}


module "ecs_frontend" {
  region             = "us-east-2"
  source             = "./modules/ecs_frontend"
  app_name           = var.app_name
  ecs_cluster_id     = aws_ecs_cluster.main.id
  subnet_ids         = module.network.public_subnet_ids
  vpc_id             = module.network.vpc_id
  frontend_image     = module.ecr.ecr_frontend_repo_url
  security_group_ids = [module.network.ecs_sg_frontend_id]
  desired_count      = 1
}

module "monitoring" {
  source       = "./modules/monitoring"
  app_name     = var.app_name
  cluster_name = "eduia-cluster"
  service_name = "eduia-service"
}
