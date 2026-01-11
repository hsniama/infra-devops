variable "location" { type = string }

variable "resource_group_name" { type = string }
variable "acr_name" { type = string }
variable "aks_name" { type = string }

variable "node_count" {
  type    = number
  default = 2
}

variable "node_vm_size" {
  type    = string
  default = "Standard_B2ts_v2"
}

variable "vnet_name" { type = string }
variable "subnet_name" { type = string }
variable "vnet_cidr" { type = string }
variable "subnet_cidr" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}
