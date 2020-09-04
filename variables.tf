# Map of the remote data state for lower level
variable lowerlevel_storage_account_name {}
variable lowerlevel_container_name {}
variable lowerlevel_key {}
variable lowerlevel_resource_group_name {}

variable tfstate_storage_account_name {}
variable tfstate_container_name {}
variable tfstate_key {}
variable tfstate_resource_group_name {}

variable tfstates {
  default = {
    caf_foundations = {
      tfstate = "caf_foundations.tfstate"
    }
    caf_networking = {
      tfstate = "aks_networking.tfstate"
    }
  }
}

variable max_length {
  default = null
}

variable landingzone_name {
  default = "aks"
}
variable level {
  default = "level3"
}
variable rover_version {
  default = null
}
variable logged_user_objectId {
  default = null
}
variable logged_aad_app_objectId {
  default = null
}
variable tags {
  default = null
}
variable diagnostics_definition {
  default = null
}
variable resource_groups {
  default = null
}
variable network_security_group_definition {
  default = null
}
variable vnets {
  default = {}
}
variable storage_accounts {
  default = {}
}
variable azuread_groups {
  default = {}
}
variable keyvaults {
  default = {}
}
variable keyvault_access_policies {
  default = {}
}

variable azure_container_registries {
  default = {}
}
variable aks_clusters {
  default = {}
}
variable virtual_machines {
  default = {}
}
variable managed_identities {
  default = {}
}
variable role_mapping {
  default = {}
}