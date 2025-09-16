data "aws_ami" "amazon_linux" {
   owners   = ["amazon"]
   filter {
     name = "name"
     values = ["aI2023-ami-*"]
   }
}

