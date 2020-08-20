
variable "tags" {}
variable "prefix" {}
variable "convention" {}
variable "aks" {}
variable "subnet_ids" {}

variable "log_analytics_workspace" {}
variable "diagnostics_map" {}

variable "enable_rbac" {
  description = "(Optional) Enable rbac cluster [default=true]"
  type        = bool
}

variable "resource_group" {}
variable "registries" {
  default = []
}