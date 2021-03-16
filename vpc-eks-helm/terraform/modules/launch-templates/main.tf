resource "aws_launch_template" "fe-nodegroup" {
  name = "fe-nodegroup-lt"

  vpc_security_group_ids = var.nodes_sg
  key_name = "demo"
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
      volume_type = "gp2"
    }
  }

  image_id = var.eks_ami_id
  user_data = base64encode(templatefile("./tpl/userdata.tpl", { NODE_TYPE = var.pods_types[0], CLUSTER_NAME = var.cluster_name, B64_CLUSTER_CA = var.ca_data, API_SERVER_URL = var.cluster_endpoint, bootstrap_extra_args=""}))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "EKS-MANAGED-NODE-FE"
    }
  }
}