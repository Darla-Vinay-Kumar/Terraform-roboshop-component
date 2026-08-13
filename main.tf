#Create Ec2 instance
 resource "aws_instance" "main" {
    ami = local.ami_id
    instance_type = "t3.micro"
    vpc_security_group_ids = [local.sg_id]
    subnet_id = local.private_subnet_ids[0]

    tags = merge(
        local.common_tags,
        {
            Name = "${local.common_name_suffix}-${var.component}"
        }
     )
 }

 # connect to intsance using remote-exec provisioner through terraform data resource.
 resource "terraform_data" "main" {
    triggers_replace = [
        aws_instance.main.id
    ]

    connection {
      type = "ssh"
      user = "ec2-user"
      password = "*****"
      host = aws_instance.main.private_ip
    }
    # terraform copies this files to the monhgodb instance and then executes the commands mentioned in remote-exec
    provisioner "file" {
       source = "bootstrap.sh"
         destination = "/tmp/bootstrap.sh"
    }

    provisioner "remote-exec" {
        inline = [

            "chmod +x /tmp/bootstrap.sh",
            "sudo sh /tmp/bootstrap.sh ${var.component} ${var.environment}"
            
        ]
    }
}
# stop instance to take image
resource "aws_ec2_instance_state" "main" {
    instance_id = aws_instance.main.id
    state = "stopped"
    depends_on = [ terraform_data.main ]
}

resource aws_ami_from_instance "main" {
    name = "${local.common_name_suffix}-${var.component}-ami"
    source_instance_id = aws_instance.main.id
    depends_on = [ aws_ec2_instance_state.main ]
    tags = merge(
        local.common_tags,
        {
            Name = "${local.common_name_suffix}-${var.component}-ami"
        }
     )
}

resource "aws_lb_target_group" "main" {
    name = "${local.common_name_suffix}-${var.component}-tg"
    port = local.tg_port
    protocol = "HTTP"
    vpc_id = local.vpc_id
    deregistration_delay = 60 # waiting period before deleting the instance from target group, default is 300 seconds, we are reducing it to 60 seconds for faster deployment   
    health_check {
        healthy_threshold = 2
        interval = 10
        path = local.health_check_path
        port = local.tg_port
        protocol = "HTTP"
        matcher = "200-299"
        timeout = 2
        unhealthy_threshold = 2
    }
    tags = merge(
        local.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-${var.component}-tg"
        }
     )
}

resource "aws_launch_template" "main" {
    name = "${local.common_name_suffix}-${var.component}-launchtemplate"
    image_id = aws_ami_from_instance.main.id
    instance_initiated_shutdown_behavior = "terminate"
    instance_type = "t3.micro"
    vpc_security_group_ids = [local.sg_id]

    #when we run terraform apply it will create a new version with the new ami id
    update_default_version = true

    #tags attached to instance
    tag_specifications {
      resource_type = "instance"
      tags = merge(
        local.common_tags,
        {
            Name = "${local.common_name_suffix}-${var.component}"
        }
        )
    }
    #tags attached to volume created by the instance
    tag_specifications {
      resource_type = "volume"
      tags = merge(
        local.common_tags,
        {
            Name = "${local.common_name_suffix}-${var.component}"
        }
        )
    }
    #tags attached to launch template
    tags = merge(
    local.common_tags,
    {
        Name = "${local.common_name_suffix}-${var.component}-launchtemplate"
    }
    )
}

resource "aws_autoscaling_group" "main" {
    name = "${local.common_name_suffix}-${var.component}-asg"
    max_size = 10
    min_size = 1
    health_check_grace_period = 100
    health_check_type = "ELB"
    desired_capacity = 1
    force_delete = false
    launch_template {
        id  = aws_launch_template.main.id
        version = aws_launch_template.main.latest_version
    }
    #vpc_zone_identifier = local.private_subnet_ids[0]

    vpc_zone_identifier = local.private_subnet_ids
    
    target_group_arns = [aws_lb_target_group.main.arn]

    instance_refresh {
      strategy = "Rolling"
      preferences {
        min_healthy_percentage = 50 # atleast 50% of instances should be healthy during the refresh process
      }
      #triggers = ["launch_template"]
    }

    dynamic "tag" { # we will get the iterator with the name as tag
        for_each = merge(
            local.common_tags,
            {
                Name = "${local.common_name_suffix}-${var.component}"
            }
        )
        content {
            key = tag.key
            value = tag.value
            propagate_at_launch = true
        }
    }
    timeouts {
      delete = "15m"
    }
}
resource "aws_autoscaling_policy" "main" {
    name = "${local.common_name_suffix}-${var.component}-policy"
    autoscaling_group_name = aws_autoscaling_group.main.name
    policy_type = "TargetTrackingScaling"
    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 75.0
    }
  
}

resource "aws_lb_listener_rule" "main" {
    #listener_arn = aws_lb_listener.backend_alb_listener.arn
    listener_arn = local.listner_arn
    priority = var.rule_priority
    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.main.arn
    }
    
    condition {
        host_header {
            values = [local.host_header]
        }
    }
}

resource "terraform_data" "main_local" {
    triggers_replace = [
        aws_instance.main.id
    ]
    depends_on = [ aws_autoscaling_policy.main]
    
    provisioner "local-exec" {
        command = "aws ec2 terminate-instances --instance-ids ${aws_instance.main.id}"
    }
}
