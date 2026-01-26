location            = "eastus"
resource_group_name = "rg-devops-dev"
acr_name            = "acrdevops1720dev" # asegurarse que sea único global
aks_name            = "aksdevops1720dev"
node_count          = 2
node_vm_size        = "Standard_D2_v3"
vnet_name           = "vnet-devops-dev"
subnet_name         = "snet-aks"
vnet_cidr           = "10.110.0.0/16"
subnet_cidr         = "10.110.1.0/24"

tags = {
  project = "devops-assessment"
  owner   = "henry"
  env     = "dev"
}
