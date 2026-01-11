#location            = "westus2"
location            = "eastus"
resource_group_name = "rg-devops-prod"
acr_name            = "acr-devops-1720-prod"
aks_name            = "aks-devops-1720-prod"
node_count          = 2
#node_vm_size        = "Standard_D2s_v3"
node_vm_size        = "Standard_D2_v3"
vnet_name           = "vnet-devops-prod"
subnet_name         = "snet-aks"
vnet_cidr           = "10.120.0.0/16"
subnet_cidr         = "10.120.1.0/24"

tags = {
  project = "devops-assessment"
  owner   = "henry"
  env     = "prod"
}
