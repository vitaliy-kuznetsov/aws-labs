resource "aws_s3_bucket" "appcode" {
  acl    = "private"
}
data "archive_file" "app_zip" {
    type        = "zip"
    output_path = "../example_app.zip"
    source_dir = "../app/"
}

resource "aws_s3_bucket_object" "upload-app" {
  bucket = aws_s3_bucket.appcode.id
  key    = "example_app.zip"
  source = "../example_app.zip"
  depends_on = [data.archive_file.app_zip]
  etag = data.archive_file.app_zip.output_md5
}

resource "aws_elastic_beanstalk_application" "labapp" {
  name        = var.eb_appname
  description = "Lab_app"
}

resource "aws_elastic_beanstalk_environment" "python_env" {
  name                = var.eb_env
  application         = var.eb_appname
  solution_stack_name = "64bit Amazon Linux 2 v3.2.0 running Python 3.8"
  depends_on = [aws_elastic_beanstalk_application.labapp]
  
  dynamic "setting" {
      for_each = var.eb_settings
      content {
        namespace = setting.value["namespace"]
        name = setting.value["name"]
        value = setting.value["value"]
      }
    }
  setting {
    namespace = "aws:elbv2:loadbalancer"
    name = "SecurityGroups"
    value = var.elb_sg
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "DisableIMDSv1"
    value = true
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "Subnets"
    value = join(",",var.eb_subnets)
  }
  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = join(",",var.elb_subnets)
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SecurityGroups"
    value = var.eb_sg
  }
  
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = aws_iam_instance_profile.eb_profile.arn
  }
}

resource "aws_elastic_beanstalk_application_version" "app-version" {
  name        = "Lab_app_1.0"
  application = var.eb_appname
  description = "Lab App"
  bucket      = aws_s3_bucket.appcode.id
  key         = aws_s3_bucket_object.upload-app.id
}

resource "null_resource" "deploy_app" {
  depends_on = [aws_elastic_beanstalk_application_version.app-version,aws_elastic_beanstalk_environment.python_env] 
  provisioner "local-exec" {
    command = "aws elasticbeanstalk update-environment --environment-name ${var.eb_env} --version-label ${aws_elastic_beanstalk_application_version.app-version.name}"
  }
}