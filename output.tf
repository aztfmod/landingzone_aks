output aks_clusters_kubeconfig {
  value = {
    for key, aks_cluster in module.caf.aks_clusters : key => {
      aks_kubeconfig_cmd       = aks_cluster.aks_kubeconfig_cmd
      aks_kubeconfig_admin_cmd = aks_cluster.aks_kubeconfig_admin_cmd
    }
  }
  sensitive = false
}

output aks_clusters {
  value     = map(var.landingzone.key, module.caf.aks_clusters)
  sensitive = true
}

output global_settings {
  value     = local.global_settings
  sensitive = true
}
 
output virtual_machines {
  value     = module.caf.virtual_machines
  sensitive = false
}