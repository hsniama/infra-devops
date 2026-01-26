output "vnet_id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.this.id
}

// Dame el id del recurso azurerm_subnet llamado aks
output "subnet_aks_id" {
  description = "The ID of the Subnet."
  value       = azurerm_subnet.aks.id
}
