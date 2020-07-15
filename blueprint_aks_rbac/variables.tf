
variable "tags" {}
variable "prefix" {}
variable "convention" {}
variable "blueprint_aks" {}
variable "subnet_id" {}

variable "log_analytics_workspace" {}
variable "diagnostics_map" {}

variable "enable_rbac" {
  description = "(Optional) Enable rbac cluster [default=true]"
  type = bool
}