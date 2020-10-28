bastion_hosts = {
  launchpad_host = {
    name               = "bastion"
    resource_group_key = "aks_spoke_re1"
    vnet_key           = "spoke_aks_re1"
    subnet_key         = "AzureBastionSubnet"
    public_ip_key      = "bastion_host_re1"

    # you can setup up to 5 profiles
    # diagnostic_profiles = {
    #   operations = {
    #     definition_key   = "bastion_host"
    #     destination_type = "log_analytics"
    #     destination_key  = "central_logs"
    #   }
    # }

  }
}