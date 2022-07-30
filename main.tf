resource "aws_instance" "Project1" {
 ami           = "ami-052efd3df9dad4825"
  instance_type = "t2.micro"
}
data "aws_availability_zones" "all" {}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  name = "project1-asg"
  min_size                  = "1"
  max_size                  = "99"
  desired_capacity          = "1"
  wait_for_capacity_timeout = "0"
  health_check_type         = "EC2"
  availability_zones  =  data.aws_availability_zones.all.names
  ## Launch template
  launch_template_name        = "project1-asg"
  launch_template_description = "Launch template example"
  update_default_version      = true
  image_id          = "ami-052efd3df9dad4825"
  instance_type     = "t3.micro"
  ebs_optimized     = true
  enable_monitoring = true
}
#Security group
resource "aws_security_group" "terraform-allow_tls" {
  name        = "terraform-allow_tls"
  description = "Allow TLS inbound traffic"
  ingress {
    description = "TLS from VPC"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#ABL
resource "aws_lb" "test" {
  name               = "project1-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terraform-allow_tls.id]
  subnets            = ["subnet-0d5d230aa92b4e66a", "subnet-074f90b1316504cf9", "subnet-07ccf553c7a59e9ab", "subnet-078c8a432871fb2fb", "subnet-09eb5c0ca9d3d665e", "subnet-012377763d43da008"]
  enable_deletion_protection = true
}

