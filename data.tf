data "aws_ami" "joindevops" {
    owners                      =       [ "973714476881" ]
    most_recent                 = true

    filter {
        name = "name"
        values =  ["Redhat-9-DevOps-Practice"]
    }

    filter {
        name = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

data "aws_ssm_parameter" "sg_id" {
    name = "/${var.project_name}/${var.environment}/${component}_sg_id"
}

data "aws_ssm_parameter" "private_subnet_ids" {
    name = "/${var.project_name}/${var.environment}/private_subnet_ids"
}


data "aws_ssm_parameter" "catalogue_sg_id" {
    name = "/${var.project_name}/${var.environment}/catalogue_sg_id"
}

data "aws_ssm_parameter" "vpc_id" {
    name = "/${var.project_name}/${var.environment}/VPC_ID"
}

data "aws_ssm_parameter" "backend_alb_listener_arn" {
    name = "/${var.project_name}/${var.environment}/backend_alb_listener_arn"
}

data "aws_ssm_parameter" "frontend_alb_listener_arn" {
    name = "/${var.project_name}/${var.environment}/frontend_alb_listener_arn"
}

