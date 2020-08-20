output "cluster_name" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  value      = azurecaf_naming_convention.aks.result
}

output "resource_group_name" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  value      = var.resource_group.name
}

output "aks_kubeconfig_cmd" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  value      = "az aks get-credentials --name ${azurecaf_naming_convention.aks.result} --resource-group ${var.resource_group.name} --overwrite-existing"
}

output "aks_kubeconfig_admin_cmd" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  value      = "az aks get-credentials --name ${azurecaf_naming_convention.aks.result} --resource-group ${var.resource_group.name} --overwrite-existing --admin"
}

output "kubelet_identity" {
  description = "User-defined Managed Identity assigned to the Kubelets"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity
}

output "identity" {
  description = "System assigned identity which is used by master components"
  value       = azurerm_kubernetes_cluster.aks.identity
}

output "kube_admin_config_raw" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
}