# VPC
resource "aws_default_vpc" "default_vpc" {
    tags = {
        Name = "default vpc"
    }
}

# Availability zones
data "aws_availability_zones" "available_zones" {}

# Subnet
resource "aws_default_subnet" "default_subnet" {
    availability_zone = data.aws_availability_zones.available_zones.names[0]

    tags = {
        Name = "default subnet"
    }
}

# Create security group for EC2 instance
resource "aws_security_group" "ec2_security_group" {
    name = var.network_security_group_name
    description = "allows ssh access on port 22"
    vpc_id = aws_default_vpc.default_vpc.id

    ingress {
        description = "ssh access"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = var.local_ip_address
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "ec2 security group"
    }
}

# https://stackoverflow.com/questions/49743220/how-to-create-an-ssh-key-in-terraform
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.example.public_key_openssh
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# EC2 Instance: Spot instance
data "aws_ami" "ec2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "ec2_instance" {
    ami                     = data.aws_ami.ec2_ami.id
    instance_type           = "t4g.xlarge"
    key_name                = aws_key_pair.generated_key.key_name
    subnet_id               = aws_default_subnet.default_subnet.id
    vpc_security_group_ids  = [aws_security_group.ec2_security_group.id]
}

output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}
