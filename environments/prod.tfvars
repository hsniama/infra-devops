location            = "eastus"
resource_group_name = "rg-devops-prod"
acr_name            = "acrdevopshprod"
aks_name            = "aks-devops-prod"
node_count          = 2
node_vm_size        = "Standard_B2s"
vnet_name           = "vnet-devops-prod"
subnet_name         = "snet-aks"
vnet_cidr           = "10.120.0.0/16"
subnet_cidr         = "10.120.1.0/24"

tags = {
  project = "devops-assessment"
  owner   = "henry"
  env     = "prod"
}
