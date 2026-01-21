resource_group_name  = "rg-tfstate-devops"
//storage_account_name = "sttfstate2e9f0a4f" //aqui pongo el nombre del storage account creado en AzureA
storage_account_name = var.STATE_SA
container_name       = "tfstate"
key                  = "prod/infra.tfstate"
