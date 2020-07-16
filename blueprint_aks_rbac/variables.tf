
variable "tags" {}
variable "prefix" {}
variable "convention" {}
variable "blueprint_aks" {}
variable "subnet_ids" {}

variable "log_analytics_workspace" {}
variable "diagnostics_map" {}

variable "enable_rbac" {
  description = "(Optional) Enable rbac cluster [default=true]"
  type        = bool
}

variable "node_pools" {
  description = "(Optional) Maps of node pools"
  default     = {}
}