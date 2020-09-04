module "caf" {
  source = "git@github.com:aztfmod/terraform-azurerm-caf-landingzone-modules.git"
  # source = "./landingzones"

  tfstates                 = local.tfstates
  tags                     = local.tags
  global_settings          = local.global_settings
  diagnostics              = local.diagnostics
  logged_user_objectId     = var.logged_user_objectId
  logged_aad_app_objectId  = var.logged_aad_app_objectId
  resource_groups          = var.resource_groups
  storage_accounts         = var.storage_accounts
  azuread_groups           = var.azuread_groups
  keyvaults                = var.keyvaults
  keyvault_access_policies = var.keyvault_access_policies
  role_mapping             = var.role_mapping
  managed_identities       = var.managed_identities
  compute = {
    virtual_machines           = var.virtual_machines
    azure_container_registries = var.azure_container_registries
    aks_clusters               = var.aks_clusters
  }

  # app_service_environments = var.app_service_environments
  # app_service_plans        = var.app_service_plans
  # database = {
  #   azurerm_redis_caches = var.azurerm_redis_caches
  #   mssql_servers        = var.mssql_servers
  # }
  # user_type                         = var.user_type
  # log_analytics                     = var.log_analytics
  # diagnostics_destinations          = var.diagnostics_destinations
  # subscriptions                     = var.subscriptions
  # azuread_apps                      = var.azuread_apps
  # azuread_api_permissions           = var.azuread_api_permissions
  # azuread_app_roles                 = var.azuread_app_roles
  # azuread_users                     = var.azuread_users
  # custom_role_definitions           = var.custom_role_definitions
}
