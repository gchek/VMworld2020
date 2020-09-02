


provider "aws" {
  region                = var.AWS_region
}

provider "vmc" {
  refresh_token         = var.vmc_token
  org_id                = var.my_org_id
}

terraform {
  backend "local" {
    path = "../../phase1.tfstate"
  }
}

/*================
Create AWS VPCs
The VPCs and subnets CIDR are set in "variables.tf" file
=================*/
module "VPCs" {
  source = "../VPCs"

  vpc201_cidr             = var.My_subnets["VPC201"]
  Subnet10-vpc201         = var.My_subnets["Subnet10-vpc201"]
  Subnet20-vpc201         = var.My_subnets["Subnet20-vpc201"]
  region                  = var.AWS_region
}

/*================
Create EC2s
=================*/
module "EC2s" {
  source = "../EC2s"

  VM-AMI                = var.VM_AMI
  Subnet10-vpc201       = module.VPCs.Subnet10-vpc201
  Subnet10-vpc201-base  = var.My_subnets["Subnet10-vpc201"]
  SG-VPC201             = module.VPCs.SG-VPC201
  key_pair              = var.key_pair
}

/*================
Create SDDC
=================*/
module "SDDC" {
  source = "../SDDC"

  my_org_id             = var.my_org_id               # ORG ID from secrets
  SDDC_Mngt             = var.My_subnets["SDDC_Mngt"] # Management IP range
  SDDC_def              = var.My_subnets["SDDC_def"]  # Default SDDC Segment
  customer_subnet_id    = module.VPCs.Subnet10-vpc201 # VPC attached subnet
  region                = var.AWS_region              # AWS region
  AWS_account           = var.AWS_account             # Your AWS account
}


