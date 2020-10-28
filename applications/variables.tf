# Map of the remote data state for lower level
variable lower_storage_account_name {}
variable lower_container_name {}
variable lower_resource_group_name {}

variable tfstate_storage_account_name {}
variable tfstate_container_name {}
variable tfstate_resource_group_name {}
# variable tfstate_key {}

variable global_settings {
  default = {}
}

# variable tenant_id {}
variable landingzone {}

variable namespaces {}

variable tags {
  default = null
  type    = map
}

variable helm_charts {}

variable landingzone_key {}
variable cluster_key {}

variable rover_version {
  default = null
}

