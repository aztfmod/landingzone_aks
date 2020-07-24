output "network_interface_ids" {

    value = module.caf-vm.network_interface_ids
}

output "primary_network_interface_id" {
    value = module.caf-vm.primary_network_interface_id
}

output "admin_username" {
    value = var.bastion_vm.os_profile.admin_username
}

# TODO - get a keyvault created to insert the ssh key and share the kv secret id instead
output "ssh_private_key_pem" {
    sensitive = true
    value = module.caf-vm.ssh_private_key_pem
}

output "msi_system_principal_id" {
    value = module.caf-vm.msi_system_principal_id
}

output "name" {
    value = module.caf-vm.name
}

output "id" {
    value = module.caf-vm.id
}

output "object" {
    sensitive = true
    value = module.caf-vm
}