#
# Deploy Azure Kubernetes Services with RBAC enabled with Azure Active Directory
#
module "blueprint_aks_rbac" {
  source = "./blueprint_aks_rbac"
  
  prefix                  = local.prefix
  convention              = var.blueprint_aks.convention
  tags                    = local.tags
  blueprint_aks           = var.blueprint_aks
  subnet_id               = lookup(local.subnet_id_by_name, var.blueprint_aks.aks_subnet_name, null)

  log_analytics_workspace = local.log_analytics_workspace
  diagnostics_map         = local.diagnostics_map

  enable_rbac             = var.enable_rbac
}


#
# Grant AKS Control plane System Assigned Identity reader + join role on the subnet AKS
#
resource "azurerm_role_definition" "aks_networking_owner" {
  name               = "caf-aks-networking_owner"
  scope              = data.azurerm_subscription.primary.id

  permissions {
    actions     = [
      "Microsoft.Network/virtualNetworks/subnets/read",
      "Microsoft.Network/virtualNetworks/subnets/join/action"
    ]
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}

resource "azurerm_role_assignment" "subnet_aks_to_aks_cluster" {
  scope               = local.subnet_id_by_name[var.blueprint_aks.aks_subnet_name]
  role_definition_id  = azurerm_role_definition.aks_networking_owner.id
  principal_id        = module.blueprint_aks_rbac.identity.0.principal_id
}
