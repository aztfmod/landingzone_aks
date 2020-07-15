
resource "azurecaf_naming_convention" "rg" {
  name          = var.blueprint_aks.cluster.resource_group_name
  prefix        = local.prefix
  resource_type = "azurerm_resource_group"
  convention    = var.convention
}

resource "azurerm_resource_group" "aks" {
  name      = azurecaf_naming_convention.rg.result
  location  = var.blueprint_aks.cluster.location
  tags      = local.tags
}

locals {
  rg_aks_name   = lookup(var.blueprint_aks.cluster, "resource_group_name", "aks")
  rg_node_name  = lookup(var.blueprint_aks.cluster, "node_resource_group", "${local.rg_aks_name}-nodes")
}

resource "azurecaf_naming_convention" "rg_node" {
  name          = local.rg_node_name
  prefix        = local.prefix
  resource_type = "azurerm_resource_group"
  convention    = var.convention
}

