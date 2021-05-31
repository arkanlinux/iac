#Vars
#Creds
variable "region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}

#Instance
variable "aws_ami" {}
variable "aws_instance" {}
variable "public_key_path" {}
variable "private_key_path" {}
variable "folder_path" {}

#Network
variable "instanceTenancy" {}
variable "dnsSupport" {}
variable "dnsHostNames" {}
variable "vpcCIDRblock" {}
variable "subnetCIDRblock" {}
variable "destinationCIDRblock" {}
variable "ingressCIDRblock" {}
variable "mapPublicIP" {}
variable "availabilityZone" {}

#Configure provider
provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

#SSH keys
resource "aws_key_pair" "developer" {
  key_name   = "deployer-key"
  public_key = file(var.public_key_path)
}

#Network
#Crate VPC
resource "aws_vpc" "test-env" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
} #End VPC

#Create the Subnet
resource "aws_subnet" "test-subnet" {
  vpc_id                  = aws_vpc.test-env.id
  cidr_block              = var.subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
} #End subnet

resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = aws_vpc.test-env.id
}

# Create the Security Group
resource "aws_security_group" "ingress-all-test" {
  vpc_id      = aws_vpc.test-env.id
  name        = "VPC Security Group"
  description = "VPC Security Group"

  # allow ingress of port 9944
  ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
  }

  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "VPC Security Group"
    Description = "VPC Security Group"
  }
} #End security group

# Route table
resource "aws_route_table" "route-table-test-env" {
  vpc_id = aws_vpc.test-env.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-env-gw.id
  }
}

resource "aws_route_table_association" "subnet-association" {
  route_table_id = aws_route_table.route-table-test-env.id
  subnet_id      = aws_subnet.test-subnet.id
}

#Configure instance
resource "aws_instance" "test-1" {
  ami             = var.aws_ami
  instance_type   = var.aws_instance
  security_groups = [aws_security_group.ingress-all-test.id]
  subnet_id       = aws_subnet.test-subnet.id
  key_name        = aws_key_pair.developer.id
}

#File output
resource "local_file" "ansible" {
  content = templatefile("${var.folder_path}/templates/ansible_inventory.tpl", {
    host-ip  = jsonencode(aws_instance.test-1.public_ip)
    key-file = jsonencode(var.private_key_path)
  })
  filename = "${var.folder_path}/ansible_inventory.yml"
}

