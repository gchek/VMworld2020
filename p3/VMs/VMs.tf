

variable "data_center"        {}
variable "cluster"            {}
variable "workload_datastore" {}
variable "compute_pool"       {}

variable "Subnet12_name"      {}
variable "Subnet13_name"      {}
variable "subnet12"           {}
variable "subnet13"           {}

variable "demo_count"         { default = 3 }


/*====================================
SDDC data
====================================*/

data "vsphere_datacenter" "dc" {
  name          = var.data_center
}
data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_datastore" "datastore" {
  name          = var.workload_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.compute_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network12" {
  name          = var.Subnet12_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network13" {
  name          = var.Subnet13_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_host" "host" {
  name          = "10.10.10.68"
  datacenter_id = data.vsphere_datacenter.dc.id
}


/*=================================================================
Deploy Blue VMs
==================================================================*/

resource "vsphere_virtual_machine" "Blue" {
  lifecycle {
    ignore_changes = [storage_policy_id, disk.0.storage_policy_id]
  }
  count = var.demo_count
  name   = "Blue-VM-${count.index + 1}"
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  datastore_id      = data.vsphere_datastore.datastore.id
  datacenter_id     = data.vsphere_datacenter.dc.id
  host_system_id    = data.vsphere_host.host.id
  folder            = "Workloads"
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout = 0

  ovf_deploy {
    remote_ovf_url = "https://vmworld2020.s3-us-west-2.amazonaws.com/photon13.ova"
    disk_provisioning = "thin"
    ovf_network_map = {
      "sddc-cgw-network-1" = data.vsphere_network.network12.id
    }
  }
  tags = [
    vsphere_tag.tag.id        # vSphere Colored VM
  ]
}

/*=================================================================
Deploy Red VMs
==================================================================*/

resource "vsphere_virtual_machine" "Red" {
  lifecycle {
    ignore_changes = [storage_policy_id, disk.0.storage_policy_id]
  }
  count = var.demo_count
  name   = "Red-VM-${count.index + 1}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id = data.vsphere_datastore.datastore.id
  datacenter_id = data.vsphere_datacenter.dc.id
  host_system_id = data.vsphere_host.host.id
  folder           = "Workloads"
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout = 0

  ovf_deploy {
    remote_ovf_url = "https://vmworld2020.s3-us-west-2.amazonaws.com/photon13.ova"
    disk_provisioning = "thin"
    ovf_network_map = {
      "sddc-cgw-network-1" = data.vsphere_network.network12.id
    }
  }
  tags = [
    vsphere_tag.tag.id        # vSphere Colored VM
  ]
}


/*=================================================================
Apply NSX tags to VMs
==================================================================*/
resource "nsxt_policy_vm_tags" "NSX_Blue_tag" {
  count = var.demo_count
  instance_id = vsphere_virtual_machine.Blue[count.index].id
  tag {
    tag   = "NSX_tag"
    scope = "Blue"
  }
}
resource "nsxt_policy_vm_tags" "NSX_Red_tag" {
  count = var.demo_count
  instance_id = vsphere_virtual_machine.Red[count.index].id
  tag {
    tag   = "NSX_tag"
    scope = "Red"
  }
}

/*=================================================================
Define vSphere tags
==================================================================*/
resource "vsphere_tag_category" "category" {
  name        = "ColoredVMs"
  cardinality = "SINGLE"
  description = "Managed by Terraform"

  associable_types = [
    "VirtualMachine"
  ]
}

resource "vsphere_tag" "tag" {
  name        = "vSphere_tag"
  category_id = vsphere_tag_category.category.id
  description = "Managed by Terraform"
}


