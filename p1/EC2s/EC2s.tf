

variable "key_pair"             {}
variable "VM-AMI"               {}

variable "Subnet10-vpc201"      {}
variable "Subnet10-vpc201-base" {}
variable "SG-VPC201"            {}


/*================
EC2 Instances
=================*/
resource "aws_network_interface" "VM1-Eth0" {
  subnet_id                     = var.Subnet10-vpc201
  security_groups               = [var.SG-VPC201]
  private_ips                   = [cidrhost(var.Subnet10-vpc201-base, 100)]
}
resource "aws_instance" "VM1" {
  ami                           = var.VM-AMI
  instance_type                 = "t2.micro"
  network_interface {
    network_interface_id        = aws_network_interface.VM1-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair
  user_data                     = file("${path.module}/user-data.ini")

  tags = {
    Name = "VM1-vpc201"
  }
}

/*================
Outputs variables for other modules to use
=================*/


output "EC2_IP"           {value = aws_instance.VM1.public_ip}
output "EC2_DNS"          {value = aws_instance.VM1.public_dns}


