variable "location" { 
  type = string
  validation {
    condition = contains(["eastus", "westus", "eastus2", "westus2"], var.location) && length(var.location) > 0
    error_message = "La ubicación debe ser una de las siguientes: eastus, westus, eastus2, westus2 y no puede estar vacía."
  } 
}

variable "resource_group_name" {
   type = string
   validation {
      condition = can(regex("^[a-zA-Z0-9._()\\-]{1,90}$", var.resource_group_name))
      error_message = "El nombre del grupo de recursos debe tener entre 1 y 90 caracteres y solo puede contener letras, números, puntos, guiones bajos, paréntesis y guiones."
   }

}
variable "acr_name" {
  type = string
  validation {
    # ACR: 5-50, lowercase alfanum
    condition     = can(regex("^[a-z0-9]{5,50}$", var.acr_name))
    error_message = "acr_name inválido. Debe ser lowercase alfanum (5-50)."
  }
}

variable "aks_name" { 
  type = string
  validation {
    # AKS: 1-63, letras/números/puntos/guiones bajos/paréntesis/guiones
    condition     = can(regex("^[a-zA-Z0-9-]{1,63}$", var.aks_name))
    error_message = "aks_name inválido. Use solo letras, números y guiones (1-63)."
  }
  
}

variable "node_count" {
  type    = number
  default = 2
  validation {
    condition = var.node_count >= 1 && var.node_count <= 2
    error_message = "node_count debe estar entre 1 y 2."
  }
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D2_v3"
  validation {
    condition = length(var.node_vm_size) > 0
    error_message = "node_vm_size no puede ser vacío."
  }
}

variable "vnet_name" { 
  type = string
  validation {
    condition = can(regex("^[a-zA-Z0-9._()\\-]{1,64}$", var.vnet_name))
    error_message = "vnet_name inválido"
  }

}

variable "subnet_name" { 
  type = string 
  validation {
    condition = can(regex("^[a-zA-Z0-9._()\\-]{1,80}$", var.subnet_name))
    error_message = "subnet_name inválido."
  }
}

variable "vnet_cidr" { 
  type = string 
  validation {
    condition = can(cidrnetmask(var.vnet_cidr))
    error_message = "vnet_cidr no es un CIDR válido."
  }
}

variable "subnet_cidr" { 
  type = string
  validation {
    condition = can(cidrnetmask(var.subnet_cidr))
    error_message = "subnet_cidr no es un CIDR válido."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
  validation {
    condition = contains(keys(var.tags), "env")
    error_message = "tags debe incluir la clave 'env' (dev/prod)."
  }
}
