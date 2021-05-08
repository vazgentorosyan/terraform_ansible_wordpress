terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_security_group" "allow_http_and_ssh" {
  name        = "allow_http_and_ssh"
  description = "Allow web and ssh inbound traffic"

  ingress {
    description      = "http from anywere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
  ingress {
    description      = "https from anywere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "ssh from anywere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "local_file" "inventory" {
 content = templatefile("inventory.tmpl",
 {
  public_ip=aws_instance.wordpress.public_ip
 }
 )
 filename = "inventory"
}

resource "aws_instance" "wordpress" {
  ami           = "ami-042e8287309f5df03"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.allow_http_and_ssh.id}"]
  key_name = "epam-new"

}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command = "sleep 120 && ansible-playbook -i inventory playbook.yml"
  
  }
  depends_on = [
    aws_instance.wordpress
  ]
  
}

