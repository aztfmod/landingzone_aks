output "prefix" {
  value = local.prefix
}
output "aks" {
  value = module.blueprint_aks.*
}

