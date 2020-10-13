module "caf" {
  source = "github.com/aztfmod/terraform-azurerm-caf?ref=0.4"

  tfstates                    = local.tfstates
  tags                        = local.tags
  global_settings             = local.global_settings
  diagnostics                 = local.diagnostics
  logged_user_objectId        = var.logged_user_objectId
  logged_aad_app_objectId     = var.logged_aad_app_objectId
  resource_groups             = var.resource_groups
  storage_accounts            = var.storage_accounts
  azuread_groups              = var.azuread_groups
  keyvaults                   = var.keyvaults
  keyvault_access_policies    = var.keyvault_access_policies
  managed_identities          = var.managed_identities
  role_mapping                = var.role_mapping
  tenant_id                   = var.tenant_id
  compute = {
    virtual_machines = var.virtual_machines
    bastion_hosts    = var.bastion_hosts
    aks_clusters     = var.aks_clusters
    azure_container_registries = var.azure_container_registries
  }
  networking = {
    vnets                             = var.vnets
    network_security_group_definition = var.network_security_group_definition
    public_ip_addresses               = var.public_ip_addresses
    private_dns                       = var.private_dns
  }
  remote_objects = {
    networking = merge(local.lower_networking, local.current_networking)
  }
}
