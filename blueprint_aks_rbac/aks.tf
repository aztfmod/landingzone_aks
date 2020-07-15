### Naming convention

resource "azurecaf_naming_convention" "aks" {
  name          = var.blueprint_aks.cluster.name
  prefix        = var.prefix
  resource_type = "azurerm_kubernetes_cluster"
  max_length    = 58
  convention    = var.convention
}

resource "azurecaf_naming_convention" "default_node_pool" {
  name          = var.blueprint_aks.cluster.default_node_pool.name
  prefix        = var.prefix
  resource_type = "aks_node_pool_linux"
  convention    = var.convention
}

### AKS cluster resource

resource "azurerm_kubernetes_cluster" "aks" {

  name                = azurecaf_naming_convention.aks.result
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = lookup(var.blueprint_aks.cluster, "dns_prefix", random_string.prefix.result)
  kubernetes_version  = lookup(var.blueprint_aks.cluster, "kubernetes_version")
  node_resource_group = azurecaf_naming_convention.rg_node.result
  
  network_profile {

    network_plugin        = var.blueprint_aks.cluster.network_policy.network_plugin
    load_balancer_sku     = var.blueprint_aks.cluster.network_policy.load_balancer_sku

    load_balancer_profile {
      managed_outbound_ip_count   = lookup(var.blueprint_aks.cluster.load_balancer_profile, "managed_outbound_ip_count", null)
      outbound_ip_prefix_ids   = lookup(var.blueprint_aks.cluster.load_balancer_profile, "outbound_ip_prefix_ids", null)
      outbound_ip_address_ids   = lookup(var.blueprint_aks.cluster.load_balancer_profile, "outbound_ip_address_ids", null)
    }

  }


  dynamic "default_node_pool" {

    for_each = var.blueprint_aks.cluster.default_node_pool == null ? [0] : [1] 

    content {
      name                  = azurecaf_naming_convention.default_node_pool.result
      vm_size               = var.blueprint_aks.cluster.default_node_pool.vm_size
      type                  = lookup( var.blueprint_aks.cluster.default_node_pool, "type", "VirtualMachineScaleSets")
      os_disk_size_gb       = lookup( var.blueprint_aks.cluster.default_node_pool, "os_disk_size_gb", null)
      availability_zones    = lookup( var.blueprint_aks.cluster.default_node_pool, "availability_zones", null)
      enable_auto_scaling   = lookup(var.blueprint_aks.cluster.default_node_pool, "enable_auto_scaling", false)
      enable_node_public_ip = lookup(var.blueprint_aks.cluster.default_node_pool, "enable_node_public_ip", false)
      node_count            = lookup(var.blueprint_aks.cluster.default_node_pool, "node_count", 1)
      max_pods              = lookup(var.blueprint_aks.cluster.default_node_pool, "max_pods", 30)
      node_labels           = lookup(var.blueprint_aks.cluster.default_node_pool, "node_labels", null)
      node_taints           = lookup(var.blueprint_aks.cluster.default_node_pool, "node_taints", null)
      vnet_subnet_id        = var.subnet_id
      tags                  = merge(local.tags, lookup(var.blueprint_aks.cluster.default_node_pool, "tags", {}))
    }

  }

  dynamic "identity" {

    for_each =  lookup(var.blueprint_aks.cluster, "identity", null) == null ? [] : [1]

    content {
      type  = var.blueprint_aks.cluster.identity.type
    }

  }


  # Enabled RBAC
  role_based_access_control {
    enabled = var.enable_rbac
    azure_active_directory {
      managed = true
      admin_group_object_ids = [data.azurerm_client_config.current.object_id]
    }
  }

  lifecycle {
    ignore_changes = [
      windows_profile,
    ]
  }

  tags = merge(local.tags, lookup(var.blueprint_aks.cluster, "tags", {}))

}

resource "random_string" "prefix" {
    length  = 10
    special = false
    upper   = false
    number  = false
}



#
# Preview features
#
locals {
  register_aks_msi_preview_feature_command = <<EOT
    az feature register -n MSIPreview --namespace Microsoft.ContainerService

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

# Can take around 30 mins to register the feature
resource "null_resource" "register_aks_msi_preview_feature" {
  provisioner "local-exec" {
    command = local.register_aks_msi_preview_feature_command
  }

  triggers = {
    command = sha256(local.register_aks_msi_preview_feature_command)
  }
}