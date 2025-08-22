provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "challenge_vpc"{
    cidr_block = "192.168.0.0/24"
    tags = {
      Name="TerraformVPC"
    }
}

resource "aws_subnet" "challenge_subnet1" {
  vpc_id            = aws_vpc.challenge_vpc.id
  cidr_block        = "192.168.0.0/26"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "TerraformSubnet"
  }
}

resource "aws_subnet" "challenge_subnet2" {
  vpc_id            = aws_vpc.challenge_vpc.id
  cidr_block        = "192.168.0.64/26"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "TerraformSubnet"
  }
}

resource "aws_internet_gateway" "IGW"{
  vpc_id=aws_vpc.challenge_vpc.id
  tags ={
    Name="internet_gateway"
  }
}

resource "aws_route_table" "rt"{
  vpc_id=aws_vpc.challenge_vpc.id
  route {
    cidr_block="0.0.0.0/0"
    gateway_id=aws_internet_gateway.IGW.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.challenge_subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_instance" "my_challenge_ec2" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.challenge_subnet1.id

  tags = {
    Name = "MyEC2Instance"
  }
}

resource "aws_security_group" "sg"{
  name="allow-ssh-traffic"{
    description="control traffic"
    vpc_id=aws_vpc.challenge_vpc.id

    ingress{
      from_port=22
      to_port=22
      protocol="tcp"
      cidr_blocks=["0.0.0.0/0"]
    }

    egress{
      from_port=0
      to_port=0
      protocol="-1"
      cidr_blocks=["0.0.0.0/0"]
    }
  }
}