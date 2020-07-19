#
# Deploy Azure Kubernetes Services with RBAC enabled with Azure Active Directory
#
module "blueprint_aks" {
  source        = "./blueprint_aks"
  for_each      = var.clusters
  prefix        = local.prefix
  convention    = var.convention
  tags          = local.tags
  blueprint_aks = each.value
  subnet_ids    = local.vnets[each.value.vnet_key].vnet_subnets

  log_analytics_workspace = local.caf_foundations_accounting[each.value.location].log_analytics_workspace
  diagnostics_map         = local.caf_foundations_accounting[each.value.location].diagnostics_map

  enable_rbac = each.value.enable_rbac
}


#
# Grant AKS Control plane System Assigned Identity reader + join role on the subnet AKS
#
# resource "azurerm_role_definition" "aks_networking_owner" {
#   for_each = var.clusters
#   name  = format("%s-caf-aks-networking_owner", "${local.prefix}-${each.value.name}")
#   scope = data.azurerm_subscription.primary.id

#   permissions {
#     actions = [
#       "Microsoft.Network/virtualNetworks/subnets/read",
#       "Microsoft.Network/virtualNetworks/subnets/join/action"
#     ]
#   }

#   assignable_scopes = [
#     data.azurerm_subscription.primary.id,
#   ]
# }

resource "azurerm_role_assignment" "subnet_aks_to_aks_cluster" {
  for_each = var.clusters
  scope              = local.vnets[each.value.vnet_key].vnet_obj.id
  role_definition_name = "Contributor"
  # role_definition_id = azurerm_role_definition.aks_networking_owner[each.key].id
  principal_id       = module.blueprint_aks[each.key].identity.0.principal_id
}
