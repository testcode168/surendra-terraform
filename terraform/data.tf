data "aws_ami" "amazon_linux" {
   owners   = ["amazon"]
   filter {
     name = "name"
     values = ["aI2023-ami-*"]
   }
}

data "template_file" "user_data" {
  template = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx
    amazon-cloudwatc-agent

    cat <<AGENT > /opt/aws/amazon-cloudwatch-agent/bin/config.json
    {
      "logs":{ 
        "logs_collected": {
          "files": {
            "collect_listlist": [
              {
                "file_path": "/var/log/messages",
                "log_group_name": "${aws_cloudwatch_log_group.ec2_logs.name}",
                "log_stream_name": "{instance_id}"
              }
            ]
        }
        }
      }
    }
    AGENT
    systemctl enable
    amazon-cloudwatc-agent
    systemctl restart
    amazon-cloudwatc-agent
    EOF
}
