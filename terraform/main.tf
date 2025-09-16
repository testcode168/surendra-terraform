# IAM Role for Ec2 SSM
resource "aws_iam_role" "Ec2c2_role" {
    name = "${var.asg_name}-Ec2-role"
    assume_role_policy = jsondecode({
        Version = "2012-10-17"
        Statement = [{
          Effect  = "Allow"
          Principal = {
            Service ="ec2.amazon.com"
          }
          Action = "sts:assume_role"
        }]
    })
  
}

resource "aws-iam-assume_role_policy_attached" "ssm_managed" {
    role  = "aws_iam_role.ec2_role.name"
    policy_arn = "arn:aws:iam::aws: CloudWatchpolicy"
  
}

resource "aws_iam_instance_profile" "ec2-profile" {
    name = "${var.asg_name}-instance-profile"
    role = "aws-iam_role.ec2-role"   
  
}

# Cloudwatch log
resource "aws_cloudwatch_log_group" "ec2_logs" {
  name  = "/asw/ec2/${var.asg_name}"
  retention_in_days = 30
}

# LB
resource "aws_security_group" "alb_sg" {
  name  = "${var.lb_name}-alb_sg"
  vpc_id = var.vpc_id
   ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "ec2_sg" {
  name  = "${var.asg_name}-sg"
  vpc_id = var.vpc_id
   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg]
   }

   egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }
}

# Ec2 template
resource "aws_launch_template" "ec2_template" {
  name_prefix = "${var.asg_name}-it"
  image_id = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2-profile.name
  }

  user_data = base64decode(var.user_data.sh)
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
}

#Auto Scaling group
resource "aws_autoscaling_group" "asg" {
  name = var.asg_name
  desired_capacity = var.desired_capacity
  max_size = var.max_size
  min_size = var.min_size
  health_check_type = "Ec2"
  vpc_zone_identifier = var.private_subnets

  launch_template {
    id = aws_launch_template.ec2_template.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["luanch_template"]
  }
}

#LB
resource "aws_alb" "alb" {
  name = var.lb_name
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = var.public_subnets
}

resource "aws_lb_target_group" "tg" {
  name = "${var.lb_name}-tg"
  port = 80
  protocol = "HTTPS"
  vpc_id = var.vpc_id
  health_check {
    path = "/"
    port = "80"
  }
}

resource "aws_autoscaling_attachment" "asg_tg" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  #alb_traget_group_arn = aws_lb_target_group.tg.arn
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.certificate_arn

  default_action {
    type = "foward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}