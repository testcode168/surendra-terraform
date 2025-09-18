variable "region" {
  description = "AWS region"
  type = string
  default = "eu-west-1"
}

variable "asg_name" {
  description = "auto scaling"
  type = string
  
}

variable "lb_name" {
  description = "lb"
  type = string 
}

variable "vpc_id" {
  description = "VPC ID"
  type = string 
}

variable "private_subnets" {
  description = "subnet ID's"
  type = list(string) 
}

variable "public_subnets" {
  description = "subnet ID's"
  type = list(string) 
}

variable "certificate_arn" {
  description = "HTTP Listener"
  type = string 
}

variable "instance_type" {
  description = "EC2 instance"
  type = string 
}

variable "desired_capacity" {
  description = "number of instance"
  type = string 
}

variable "max_size" {
  description = "instances"
  type = number
  default = 4
}

variable "min_size" {
  description = "instances"
  type = number
  default = 2
}

variable "test" {
  description = "Ec2"
  type = string
  default = ""
}
