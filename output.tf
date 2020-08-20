output "prefix" {
  value = local.prefix
}
output "aks" {
  value = module.aks.*
}

output "jumpboxes" {
  value = module.bastion_vm.*
}