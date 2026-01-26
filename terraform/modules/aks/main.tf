resource "azurerm_kubernetes_cluster" "aks" {
    name = var.aks_name
    location = var.location
    resource_group_name = var.resource_group_name
    dns_prefix = var.dns_prefix

    default_node_pool {
        name = "system"
        node_count = var.node_count
        vm_size = var.node_vm_size
        vnet_subnet_id = var.subnet_id
        type = "VirtualMachineScaleSets"
    }

    identity {
        type = "SystemAssigned"
    }

    oidc_issuer_enabled = true
    workload_identity_enabled = true

    network_profile {
      network_plugin = "azure"
      load_balancer_sku = "standard"
      outbound_type = "loadBalancer"
    }

    tags = var.tags

    lifecycle {
      # Evita recreaciones tontas por diffs/cambios menores (segun evolucione Azure API)
      // Le deicmos a terraform: no te preocupes si el número de nodos del pool cambia en Azure, no lo uses como motivo para recrear el cluster.
      ignore_changes = [ 
        default_node_pool[0].node_count
       ]
    }

}