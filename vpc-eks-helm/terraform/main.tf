
provider "aws" {
  region  = local.region
}

provider "null" {
  # Configuration options
}

#### Fetching AZs ####
data "aws_availability_zones" "avz" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}


module "vpc" {
  source          = "./modules/vpc/"
  azs             = local.vpc.azs
  subnet_count  = length(local.vpc.azs)
  vpc_cidr        = local.vpc.vpc_cidr
  secondary_cidr  = local.vpc.secondary_cidr
  standard_tags   = local.standard_tags
  eks_tags        = local.eks_sn_tags
}

module "security-groups" {
  source          = "./modules/security-groups/"
  vpc_id = module.vpc.vpc_id
  standard_tags   = local.standard_tags
  cluster_sg = module.eks.cluster_security_group_id
  eks_sg_tags = local.eks_sg_tags
}

module "launch-templates" {
  source = "./modules/launch-templates/"
  subnets = module.vpc.nodes-subnets
  vpc_id = module.vpc.vpc_id
  nodes_sg = [module.security-groups.nodes-sg,module.eks.cluster_security_group_id]
  eks_ami_id = "ami-066fad1ae541d1cf9"
  eks_ami_id_bottlerocket = "ami-0eef3239c2ca58597"
  cluster_name = module.eks.cluster_id
  ca_data = module.eks.cluster_certificate_authority_data
  cluster_endpoint = module.eks.cluster_endpoint
  pods_types = local.pods_types
}

resource "aws_kms_key" "eks" {
  description = "EKS Secret Encryption Key"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  cluster_name = local.eks_cluster_name
  cluster_version = "1.18"
  subnets = module.vpc.nodes-subnets
  vpc_id = module.vpc.vpc_id

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  node_groups = {
    ng0 = {
      name = "NodeGroup0"
      subnets = module.vpc.nodes-subnets
      instance_types = ["t3.small","t3a.small"]
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 2
      capacity_type = "SPOT"
      map_roles = local.eks.map_roles
      
      launch_template_id      = module.launch-templates.fe-lt.id
      launch_template_version = module.launch-templates.fe-lt.default_version

      additional_tags = {
        CustomTag = "ng0"
      }
    }
    }
  }

output "lb-sg" {
  value = module.security-groups.lb-sg
 }
