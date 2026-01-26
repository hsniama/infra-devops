locals {
  # dns_prefix para AKS: solo letras/números/guiones, sin underscores
  dns_prefix = "devops-${replace(lower(var.aks_name), "_", "-")}"
}
