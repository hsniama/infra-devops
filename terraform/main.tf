module "rg" {
  source   = "./modules/rg"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "network" {
  source = "./modules/network"

  location            = module.rg.location
  resource_group_name = module.rg.name

  vnet_name = var.vnet_name
  vnet_cidr = var.vnet_cidr
  tags      = var.tags

  subnet_name = var.subnet_name
  subnet_cidr = var.subnet_cidr
}

module "acr" {
  source              = "./modules/acr"
  acr_name            = var.acr_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  tags                = var.tags
}

module "aks" {
  source              = "./modules/aks"
  aks_name            = var.aks_name
  location            = module.rg.location
  resource_group_name = module.rg.name
  dns_prefix          = local.dns_prefix

  node_count   = var.node_count
  node_vm_size = var.node_vm_size
  subnet_id    = module.network.subnet_aks_id
  tags         = var.tags
}

# Permisos para que AKS (kubelet identity) pueda pull desde ACR
resource "azurerm_role_assignment" "aks_to_acr" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull" // Permiso mínimo necesario para que AKS pueda hacer pull de imágenes desde ACR
  principal_id         = module.aks.kubelet_object_id

  // A veces Azure tarda un poco en propagar la identidad del AKS, por eso el depends_on
  depends_on = [module.aks, module.acr] // Asegura que ambos módulos estén creados antes de asignar el rol
}