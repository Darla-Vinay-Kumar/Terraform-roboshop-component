locals {
    common_name_suffix = "${var.project_name}-${var.environment}"
    ami_id = data.aws_ami.joindevops.id
    private_subnet_ids = split(",",data.aws_ssm_parameter.private_subnet_ids.value)
    private_subnet_id = split(",",data.aws_ssm_parameter.private_subnet_ids.value)[0]
    catalogue_sg_id = data.aws_ssm_parameter.catalogue_sg_id.value
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    sg_id = data.aws_ssm_parameter.sg_id.value
    tg_port = var.component == "frontend" ? 80 : 8080
    health_check_path = var.component == "frontend" ? "/" : "/health"
    backend_alb_listener_arn = data.aws_ssm_parameter.backend_alb_listener_arn.value
    frontend_alb_listener_arn = data.aws_ssm_parameter.frontend_alb_listener_arn.value
    listner_arn = var.component == "frontend" ? local.frontend_alb_listener_arn : local.backend_alb_listener_arn    
    host_header = var.component == "frontend" ? "${var.project_name}.${var.environment}.${var.domain_name}" : "${var.component}.backend-alb-${var.environment}.${var.domain_name}"

    common_tags = {
        project = var.project_name
        Environment = var.environment
        Terraform = "true"
    }
}