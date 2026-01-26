resource "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku = "Basic"
  admin_enabled = false
  tags = var.tags

  lifecycle {
    // Si lo pongo true, evito que se destruya el ACR al hacer terraform destroy.
    prevent_destroy = false
  }
}