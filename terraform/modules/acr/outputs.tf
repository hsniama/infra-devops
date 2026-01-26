output "acr_id" {
  description = "ID del Azure Container Registry"
  value       = azurerm_container_registry.this.id
}

output "acr_name" {
  description = "Nombre del Azure Container Registry"
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "Login server del Azure Container Registry"
  value       = azurerm_container_registry.this.login_server
}