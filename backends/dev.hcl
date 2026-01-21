resource_group_name  = "rg-tfstate-devops"
//storage_account_name = "sttfstate2e9f0a4f" //pongo el nombre del storage account creado en Azure
storage_account_name = var.STATE_SA
container_name       = "tfstate"
key                  = "dev/infra.tfstate"
