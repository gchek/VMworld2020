/*================
REGIONS map:
==================
us-east-1         US East (N. Virginia)
us-east-2	      US East (Ohio)
us-west-1	      US West (N. California)
us-west-2	      US West (Oregon)
ca-central-1	  Canada (Central)

eu-west-1	      EU (Ireland)
eu-central-1	  EU (Frankfurt)
eu-west-2	      EU (London)
      EU (Paris)
      EU (stokholm)

ap-northeast-1	  Asia Pacific (Tokyo)
ap-northeast-2	  Asia Pacific (Seoul)
ap-southeast-1	  Asia Pacific (Singapore)
ap-southeast-2	  Asia Pacific (Sydney)
ap-south-1	      Asia Pacific (Mumbai)
sa-east-1	      South America (São Paulo)
=================*/

variable "AWS_account"  {}
variable "vmc_token"    {}
variable "my_org_id"    {}
variable "AWS_region"   {default = "us-west-2"}
variable "key_pair"     {default = "set-emea-oregon" }

variable "DB_name"      {default = "PhotoAppDB"}
variable "DB_user"      {default = "admin"}
variable "DB_pass"      {default = "VMware1!"}


/*================
Subnets IP ranges
=================*/
variable "My_subnets" {
  default = {

    SDDC_Mngt             = "10.10.10.0/23"
    SDDC_def              = "192.168.1.0/24"
  
    VPC201                = "172.201.0.0/16"
    Subnet10-vpc201       = "172.201.10.0/24"
    Subnet20-vpc201       = "172.201.20.0/24"
    Subnet30-vpc201       = "172.201.30.0/24"
  }
}
/*================
VM AMIs
=================*/
# variable "VM_AMI"               { default = "ami-07cda0db070313c52" } # Amazon Linux 2 AMI (HVM), SSD Volume Type - Frankfurt

variable "VM_AMI"               { default = "ami-04590e7389a6e577c" } # Amazon Linux 2 AMI (HVM), SSD Volume Type - Oregon




