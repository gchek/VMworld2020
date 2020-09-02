
/*================
Create VPCs
Create respective Internet Gateways
Create subnets
Create route tables
create security groups
=================*/

variable "vpc201_cidr"      {}
variable "Subnet10-vpc201"  {}
variable "Subnet20-vpc201"  {}
variable "region"         {}

/*================
VPC
=================*/
resource "aws_vpc" "vpc201" {
  cidr_block            = var.vpc201_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = {
    Name = "TF-VPC201"
  }
}

/*================
IGWs
=================*/
resource "aws_internet_gateway" "vpc201-igw" {
  vpc_id = aws_vpc.vpc201.id
  tags = {
    Name = "TF-VPC201-IGW"
  }
}

/*================
Subnets in VPC1
=================*/
# Get Availability zones in the Region
data "aws_availability_zones" "AZ" {}

resource "aws_subnet" "Subnet10-vpc201" {
  vpc_id     = aws_vpc.vpc201.id
  cidr_block = var.Subnet10-vpc201
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.AZ.names[0]
  tags = {
    Name = "TF-Subnet10-vpc201"
  }
}
resource "aws_subnet" "Subnet20-vpc201" {
  vpc_id     = aws_vpc.vpc201.id
  cidr_block = var.Subnet20-vpc201
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.AZ.names[1]
  tags = {
    Name = "TF-Subnet20-vpc201"
  }
}

/*======================
default route table VPC1
=======================*/

resource "aws_default_route_table" "vpc1-RT" {
  default_route_table_id = aws_vpc.vpc201.default_route_table_id

  lifecycle {
    ignore_changes = [route] # ignore any manually or ENI added routes
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc201-igw.id
  }

  tags = {
    Name = "TF-RT-VPC201"
  }
}



/*================
Route Table association
=================*/

resource "aws_route_table_association" "vpc201_10" {
  subnet_id      = aws_subnet.Subnet10-vpc201.id
  route_table_id = aws_default_route_table.vpc1-RT.id
}


/*================
Security Groups
=================*/

resource "aws_security_group" "SG-VPC201" {
  name    = "SG-VPC201"
  vpc_id  = aws_vpc.vpc201.id
  tags = {
    Name = "SG-VPC201"
  }
  #SSH, all PING and others
  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow all PING"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow MySQL"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow iPERF3"
    from_port = 5201
    to_port = 5201
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_default_security_group" "default" {

  vpc_id = aws_vpc.vpc201.id

  ingress {
    description = "Default SG for VPC201"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  ingress{
     description = "Include EC2 SG in VPC201 default SG"
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     security_groups = [aws_security_group.SG-VPC201.id]
   }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Default VPC201-SG"
  }
}


/*==================
  S3 VPC end point
===================*/
 resource "aws_vpc_endpoint" "s3" {
   vpc_id          = aws_vpc.vpc201.id
   service_name    = "com.amazonaws.${var.region}.s3"
   route_table_ids = [aws_default_route_table.vpc1-RT.id]
 }


/*===================================
  Outputs variables for other modules
====================================*/
output "VPC1_id"              {value = aws_vpc.vpc201.id}
output "Subnet10-vpc201"      {value = aws_subnet.Subnet10-vpc201.id}
output "Subnet20-vpc201"      {value = aws_subnet.Subnet20-vpc201.id}
output "SG-VPC201"            {value = aws_security_group.SG-VPC201.id}





