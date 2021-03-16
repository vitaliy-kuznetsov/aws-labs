locals {
    region = "eu-west-1"
    standard_tags = {
        Owner = "vitaliyku"
    }
    vpc = {
        name = "LabVPC"
        azs = ["eu-west-1a","eu-west-1b"]
        cidr = "10.30.0.0/16"
    }
    container = {
        image = "nginx:latest"
        name = "nginx"
    }
    eb = {
        env = "python-env"
        settings = [
            {    
                namespace = "aws:elasticbeanstalk:environment"     
                name = "EnvironmentType"
                value = "LoadBalanced"
            },
            {
                namespace = "aws:elasticbeanstalk:environment"     
                name = "LoadBalancerType"
                value = "application"
            }
        ]
    }
    app = {
        port = 80
        name = "Lab-App"
        domain_name = "lab-app.com"
    }
    db = {
            storage = 30
            engine = "postgres"
            instance_type = "db.t3.small"
            name = "labdb"
            username = "root"
            multi_az = false
            port = 5432
    }
    alb = {
        name = "lab-alb"
    }
    
    
}
