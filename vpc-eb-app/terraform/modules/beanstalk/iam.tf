resource "aws_iam_role" "beanstalk_ec2_role" {
    name = "beanstalk-ec2-role"
    managed_policy_arns = ["arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier","arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker","arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"]
    assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Sid =  ""
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
        }
      Action = "sts:AssumeRole"
    },
  ]
})
}

resource "aws_iam_instance_profile" "eb_profile" {
  name = "eb_profile"
  role = aws_iam_role.beanstalk_ec2_role.name
}