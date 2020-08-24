#
# Deploy Azure Kubernetes Services with RBAC enabled with Azure Active Directory
#



module "acr" {
    source  = "./acr"
    for_each      = var.registries
    prefix        = local.prefix
    convention    = var.convention
    tags          = local.tags
    acr           = each.value
    log_analytics_workspace = local.caf_foundations_accounting[azurerm_resource_group.rg[each.value.resource_group_key].location].log_analytics_workspace
    diagnostics_map         = local.caf_foundations_accounting[azurerm_resource_group.rg[each.value.resource_group_key].location].diagnostics_map
    resource_group              = azurerm_resource_group.rg[each.value.resource_group_key]
    vnets         = local.vnets
}

output "subnet_ids" {
  value = module.acr.*
}

module "aks" {
  source        = "./aks"
  for_each      = var.clusters
  prefix        = local.prefix
  convention    = var.convention
  tags          = local.tags
  aks = each.value
  subnet_ids    = local.vnets[each.value.vnet_key].vnet_subnets
  log_analytics_workspace = local.caf_foundations_accounting[azurerm_resource_group.rg[each.value.resource_group_key].location].log_analytics_workspace
  diagnostics_map         = local.caf_foundations_accounting[azurerm_resource_group.rg[each.value.resource_group_key].location].diagnostics_map
  enable_rbac = each.value.enable_rbac
  resource_group = azurerm_resource_group.rg[each.value.resource_group_key]
  registries    = module.acr
}

module "bastion_vm" {
  source  = "./bastion_vm"
  for_each = var.jumpboxes
  
  prefix                        = local.prefix
  convention                    = var.convention
  bastion_vm                    = each.value
  subnet_id                     = local.vnets[each.value.vnet_key].vnet_subnets[each.value.subnet_key]
  tags                          = local.tags
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
  principal_id       = module.aks[each.key].identity.0.principal_id
}
