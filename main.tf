provider "aws" {
  region = "us-east-2"


default_tags {
    tags = {
      Name = "student-930606-practice4"
      Subject = "cloud-programming"
      # Chapter = "practice4"
    }
  }
}

variable "vpc_main_cidr" {
  description = "VPC main CIDR block"
  default     = "192.168.17.0/24"
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_main_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
}

resource "aws_subnet" "pub_sub_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.my_vpc.cidr_block, 4, 0)
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pub_sub_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.my_vpc.cidr_block, 4, 1)
  availability_zone       = "us-east-2c"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "prv_sub_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.my_vpc.cidr_block, 4, 2)
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "prv_sub_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.my_vpc.cidr_block, 4, 3)
  availability_zone = "us-east-2c"
}

resource "aws_subnet" "prv_sub_db_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.my_vpc.cidr_block, 4, 4)
  availability_zone = "us-east-2a"

  tags = {
    Name = "prv-sub-db-1"
  }
}

resource "aws_subnet" "prv_sub_db_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.my_vpc.cidr_block, 4, 5)
  availability_zone = "us-east-2c"

  tags = {
    Name = "prv-sub-db-2"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table" "prv_rt1" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block    = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1.id
  }
}

resource "aws_route_table" "prv_rt2" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block    = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_2.id
  }
}

resource "aws_route_table_association" "pub_rt_asso" {
  subnet_id      = aws_subnet.pub_sub_1.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pub_rt_asso2" {
  subnet_id      = aws_subnet.pub_sub_2.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "prv_rt1_asso" {
  subnet_id      = aws_subnet.prv_sub_1.id
  route_table_id = aws_route_table.prv_rt1.id
}

resource "aws_route_table_association" "prv_rt2_asso" {
  subnet_id      = aws_subnet.prv_sub_2.id
  route_table_id = aws_route_table.prv_rt2.id
}

resource "aws_route_table_association" "prv_db_rt1_asso" {
  subnet_id      = aws_subnet.prv_sub_db_1.id
  route_table_id = aws_route_table.prv_rt1.id
}

resource "aws_route_table_association" "prv_db_rt2_asso" {
  subnet_id      = aws_subnet.prv_sub_db_2.id
  route_table_id = aws_route_table.prv_rt2.id
}

resource "aws_eip" "nat_eip1" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.pub_sub_1.id
  depends_on    = [aws_internet_gateway.my_igw, aws_vpc.my_vpc]
}

resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.pub_sub_2.id
  depends_on    = [aws_internet_gateway.my_igw, aws_vpc.my_vpc]
}