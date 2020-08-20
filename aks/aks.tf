### Naming convention

resource "azurecaf_naming_convention" "aks" {
  name          = var.aks.name
  prefix        = var.prefix
  resource_type = "azurerm_kubernetes_cluster"
  max_length    = 58
  convention    = var.convention
}

resource "azurecaf_naming_convention" "default_node_pool" {
  name          = var.aks.default_node_pool.name
  prefix        = var.prefix
  resource_type = "aks_node_pool_linux"
  convention    = var.convention
}

locals {
  rg_node_name = lookup(var.aks, "node_resource_group", "${var.resource_group.name}-nodes")
}
resource "azurecaf_naming_convention" "rg_node" {
  name          = local.rg_node_name
  prefix        = local.prefix
  resource_type = "azurerm_resource_group"
  convention    = var.convention
}


### AKS cluster resource

resource "azurerm_kubernetes_cluster" "aks" {

  name                    = azurecaf_naming_convention.aks.result
  location                = var.resource_group.location
  resource_group_name     = var.resource_group.name
  dns_prefix              = lookup(var.aks, "dns_prefix", random_string.prefix.result)
  kubernetes_version      = lookup(var.aks, "kubernetes_version")
  node_resource_group     = azurecaf_naming_convention.rg_node.result
  private_cluster_enabled = lookup(var.aks, "private_cluster_enabled", false)

  network_profile {

    network_plugin    = var.aks.network_policy.network_plugin
    load_balancer_sku = var.aks.network_policy.load_balancer_sku

    # load_balancer_profile {
    #   managed_outbound_ip_count = lookup(var.aks.load_balancer_profile, "managed_outbound_ip_count", null)
    #   outbound_ip_prefix_ids    = lookup(var.aks.load_balancer_profile, "outbound_ip_prefix_ids", null)
    #   outbound_ip_address_ids   = lookup(var.aks.load_balancer_profile, "outbound_ip_address_ids", null)
    # }

    outbound_type = lookup(var.aks, "outbound_type", "loadBalancer")
  }


  dynamic "default_node_pool" {

    for_each = var.aks.default_node_pool == null ? [0] : [1]

    content {
      name                  = azurecaf_naming_convention.default_node_pool.result
      vm_size               = var.aks.default_node_pool.vm_size
      type                  = lookup(var.aks.default_node_pool, "type", "VirtualMachineScaleSets")
      os_disk_size_gb       = lookup(var.aks.default_node_pool, "os_disk_size_gb", null)
      availability_zones    = lookup(var.aks.default_node_pool, "availability_zones", null)
      enable_auto_scaling   = lookup(var.aks.default_node_pool, "enable_auto_scaling", false)
      enable_node_public_ip = lookup(var.aks.default_node_pool, "enable_node_public_ip", false)
      node_count            = lookup(var.aks.default_node_pool, "node_count", 1)
      max_pods              = lookup(var.aks.default_node_pool, "max_pods", 30)
      node_labels           = lookup(var.aks.default_node_pool, "node_labels", null)
      node_taints           = lookup(var.aks.default_node_pool, "node_taints", null)
      vnet_subnet_id        = var.subnet_ids[var.aks.default_node_pool.subnet_key]

      tags = merge(local.tags, lookup(var.aks.default_node_pool, "tags", {}))
    }

  }

  dynamic "identity" {
    for_each = lookup(var.aks, "identity", null) == null ? [] : [1]

    content {
      type = var.aks.identity.type
    }
  }

  # Enabled RBAC
  role_based_access_control {
    enabled = lookup(var.aks, "enable_rbac", true)
    azure_active_directory {
      managed                = true
      admin_group_object_ids = [data.azurerm_client_config.current.object_id]
    }
  }

  lifecycle {
    ignore_changes = [
      windows_profile,
    ]
  }

  tags = merge(local.tags, lookup(var.aks, "tags", {}))

}

resource "random_string" "prefix" {
  length  = 10
  special = false
  upper   = false
  number  = false
}


resource "azurerm_role_assignment" "aks_acr" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  for_each = lookup(var.aks,"acr_keys",{})
  scope                = var.registries[each.value].object.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

#
# Preview features
#
locals {
  register_aks_msi_preview_feature_command = <<EOT
    az feature register -n AAD-V2 --namespace Microsoft.ContainerService

    isRegistered=$(az feature list --query properties.state=="Registered")

    while [ ! $isRegistered == true ]
    do
      echo "waiting for the provider to register"
      sleep 20
      isRegistered=$(az feature list --query properties.state=="Registered")
    done
    echo "Feature registered"
    az provider register -n Microsoft.ContainerService
  EOT
}

resource "azurerm_kubernetes_cluster_node_pool" "nodepools" {
  for_each              = lookup(var.aks, "node_pools", {})
  name                  = each.value.name
  mode                  = lookup(each.value, "mode", "User")
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vnet_subnet_id        = var.subnet_ids[lookup(each.value, "subnet_key", var.aks.default_node_pool.subnet_key)]
  vm_size               = each.value.vm_size
  os_disk_size_gb       = lookup(each.value, "os_disk_size_gb", null)
  availability_zones    = lookup(each.value, "availability_zones", null)
  enable_auto_scaling   = lookup(each.value, "enable_auto_scaling", false)
  enable_node_public_ip = lookup(each.value, "enable_node_public_ip", false)
  node_count            = lookup(each.value, "node_count", 1)
  max_pods              = lookup(each.value, "max_pods", 30)
  node_labels           = lookup(each.value, "node_labels", null)
  node_taints           = lookup(each.value, "node_taints", null)
  orchestrator_version  = lookup(each.value, "orchestrator_version", var.aks.kubernetes_version)


}

# Can take around 30 mins to register the feature
resource "null_resource" "register_aks_msi_preview_feature" {
  provisioner "local-exec" {
    command = local.register_aks_msi_preview_feature_command
  }

  triggers = {
    command = sha256(local.register_aks_msi_preview_feature_command)
  }
}