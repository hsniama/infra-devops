locals {
  dns_prefix = "devops-${replace(var.aks_name, "_", "-")}"
}
