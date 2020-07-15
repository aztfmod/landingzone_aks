output "prefix" {
  value = local.prefix
}


output "aks" {
  value = {
    cluster_name          = module.blueprint_aks_rbac.cluster_name
    resource_group_name   = module.blueprint_aks_rbac.resource_group_name
    rbac_enabled          = var.enable_rbac
    kubeconfig_cmd        = module.blueprint_aks_rbac.aks_kubeconfig_cmd
    kubeconfig_admin_cmd  = module.blueprint_aks_rbac.aks_kubeconfig_admin_cmd
  }
}

output "kube_admin_config_raw" {
    value = module.blueprint_aks_rbac.kube_admin_config_raw
    sensitive = true
}