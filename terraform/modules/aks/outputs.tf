output "aks_name" {
    description = "The name of the AKS cluster"
    value       = azurerm_kubernetes_cluster.this.name
}

output "oidc_issuer_url" {
    description = "The OIDC issuer URL for the AKS cluster"
    value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

# Importante para ArcPull
# Devuelve el ID único de la identidad administrada del kubelet del cluster AKS.
output "kubelet_object_id" {
    description = "The object ID of the AKS cluster's kubelet identity"
    value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

/*
El kubelet identity es una Managed Identity que AKS usa para interactuar con otros recursos de Azure (por ejemplo, leer secretos en Key Vault, acceder a registros en ACR, etc.).

- Tener el object_id expuesto como output permite:
- Darle permisos en Azure AD o RBAC fácilmente.
- Usarlo en otros módulos Terraform (ej. asignar roles).
- Integrarlo con herramientas como ArcPull (según tu comentario), que necesitan saber qué identidad usar.
*/