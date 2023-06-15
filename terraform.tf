provider "aws" {
  region  = "us-east-1"
  profile = "ABDULRAHMAN"
}



#vpc
resource "aws_vpc" "demo_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = false

  tags = {
    Name = "dev"
  }
}

#subnet
resource "aws_subnet" "demo_subnet" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "dev_subnet"
  }
}

#internet gateway
resource "aws_internet_gateway" "demo_gw" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "dev_igw"
  }
}

#route table
resource "aws_route_table" "dev_route_table" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_gw.id
  }


  tags = {
    Name = "demo_route_table"
  }
}

#route table association
resource "aws_route_table_association" "dev_route_association" {
  subnet_id      = aws_subnet.demo_subnet.id
  route_table_id = aws_route_table.dev_route_table.id
}

#create security group
resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow https inbound traffic"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    description = "https web traffic from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http web traffic from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_server_security_group"
  }
}

resource "aws_instance" "first_server" {
  ami                    = "ami-09988af04120b3591"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.demo_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_https.id]
  availability_zone      = "us-east-1a"
  key_name               = "lampstack"

  tags = {
    Name = "first_server"
  }
}
