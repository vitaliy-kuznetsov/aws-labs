
provider "aws" {
  region  = local.region
}

module "vpc" {
  source          = "./modules/vpc/"
  azs             = local.vpc.azs
  subnet_count  = length(local.vpc.azs)
  vpc_cidr        = local.vpc.cidr
  standard_tags   = local.standard_tags
  vpc_name  = local.vpc.name
}
module "security-groups" {
  source = "./modules/security-groups/"
  vpc_id = module.vpc.vpc_id
  standard_tags   = local.standard_tags
  app_port = local.app.port
  db_port = local.db.port
}

module beanstalk {
  source = "./modules/beanstalk/"
  eb_settings = local.eb.settings
  eb_subnets = module.vpc.nodes_subnets
  elb_sg = module.security-groups.elb-sg
  elb_subnets = module.vpc.elb_subnets
  eb_sg = module.security-groups.nodes-sg
  eb_appname = local.app.name
  eb_env = local.eb.env
}

module rds {
  source = "./modules/rds/"
  db_storage = local.db.storage
  db_engine = local.db.engine
  db_instance = local.db.instance_type
  db_name = local.db.name
  db_username = local.db.username
  db_multi_az = local.db.multi_az
  db_subnets = module.vpc.rds_subnets
  db_sg = module.security-groups.rds-sg
  
}