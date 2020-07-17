# Map of the remote data state
variable "lowerlevel_storage_account_name" {}
variable "lowerlevel_container_name" {}
variable "lowerlevel_resource_group_name" {}

variable "workspace" {}

variable "clusters" {}
variable "convention" {}

variable "tags" {
  default = {}
  type    = map
}

variable "enable_rbac" {
  description = "(Optional) Enable rbac cluster [default=true]"
  default     = true
}

variable tfstate_landingzone_networking {
  default = "landingzone_networking.tfstate"
}

variable tfstate_landingzone_caf_foundations {
  default = "landingzone_caf_foundations.tfstate"
}