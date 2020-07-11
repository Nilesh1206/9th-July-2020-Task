provider "aws" {
     region = "ap-south-1"
     
 }

resource "aws_vpc" "myvpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "aws-vpc"
  }
} 

resource "aws_security_group" "my_security"{
   name            = "my_security"
   description     = " Allows SSH and HTTP"
   vpc_id          = aws_vpc.myvpc.id
 
   ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks =["0.0.0.0/0"]
        }
    
    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks =["0.0.0.0/0"]
        }

    ingress {
        description = "TCP"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks =["0.0.0.0/0"]
        }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks =["0.0.0.0/0"]
        }
    
      tags ={
        Name = "my_security"
   }
}


resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "192.168.0.0/24"
  availability_zone= "ap-south-1a"
  map_public_ip_on_launch ="true"

  tags = {
    Name = "aws-subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "192.168.1.0/24"
  availability_zone= "ap-south-1b"

  tags = {
    Name = "aws-subnet2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id
   
   tags = {
      Name = "aws-internet-gw"
   }
}

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "my-route-table"
  }
}

resource "aws_route_table_association" "ng" {
    subnet_id      = aws_subnet.subnet1.id
    route_table_id = aws_route_table.route-table.id
 }

resource "aws_route_table_association" "ng1" {
    subnet_id      = aws_subnet.subnet2.id
    route_table_id = aws_route_table.route-table.id
 }

resource "aws_instance" "myins" {
   ami          = "ami-7e257211"
   instance_type= "t2.micro"
   key_name     = "newkey"
   vpc_security_group_ids = [aws_security_group.my_security.id]
   subnet_id    = aws_subnet.subnet1.id
   
      tags ={
          Name = "Wp-os"
     }
}


resource "aws_instance" "myins1" {
   ami          = "ami-08706cb5f68222d09"
   instance_type= "t2.micro"
   key_name     = "newkey"
   vpc_security_group_ids = [aws_security_group.my_security.id]
   subnet_id    = aws_subnet.subnet2.id
   
      tags ={
          Name = "Mysql-os"
     }
}











