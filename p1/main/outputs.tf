/*================
Outputs from Various Module
=================*/

output "sddc_subnet"            {value = module.VPCs.Subnet10-vpc201}
output "proxy_url"              {value = module.SDDC.proxy_url}
output "VM1_IP"                 {value = module.EC2s.EC2_IP}
output "VM1_DNS"                {value = module.EC2s.EC2_DNS}
output "vc_url"                 {value = module.SDDC.vc_url}
output "vc_public_IP"           {value = module.SDDC.vc_public_IP}
output "cloud_username"         {value = module.SDDC.cloud_username}
output "cloud_password"         {
  sensitive = true
  value = module.SDDC.cloud_password
}




