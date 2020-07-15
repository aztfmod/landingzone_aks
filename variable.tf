# Map of the remote data state
variable "lowerlevel_storage_account_name" {}
variable "lowerlevel_container_name" {}
variable "lowerlevel_resource_group_name" {}

variable "workspace" {}

variable "blueprint_aks" {}

variable "tags" {
  default = {}
  type = map
}

variable "enable_rbac" {
  description = "(Optional) Enable rbac cluster [default=true]"
  default = true
}