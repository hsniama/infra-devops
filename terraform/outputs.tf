output "resource_group_name" {
  value = module.rg.name
}

output "acr_name" {
  value = module.acr.acr_name
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "aks_name" {
  value = module.aks.aks_name
}

output "oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}
