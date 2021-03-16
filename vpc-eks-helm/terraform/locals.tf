locals {
    eks_cluster_name = "lab-eks"
    region = "eu-west-1"
    standard_tags = {
        Owner = "vitaliyku"
    }
    eks_sn_tags = {
        "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
        "kubernetes.io/role/elb" = "1"
    }
    eks_sg_tags = {
        "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"
    }
    pods_types = ["fe-pods"]
    vpc = {
        azs = ["eu-west-1a","eu-west-1b"]
        vpc_cidr = "10.30.0.0/16"
        secondary_cidr = "10.64.0.0/16"
    }
    eks ={
        map_roles =[]
    }

    
    
}
