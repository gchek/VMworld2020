/*================
Outputs from Various Module
=================*/


output "segment12_name"         {value = module.NSX.segment12_name}
output "segment13_name"         {value = module.NSX.segment13_name}
output "subnet12"               {value = trimsuffix(var.VMC_subnets.Subnet12, "/??")}
output "subnet13"               {value = trimsuffix(var.VMC_subnets.Subnet13, "/??")}


