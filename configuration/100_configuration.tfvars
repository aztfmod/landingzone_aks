#
# This is a personalized version of the launchpad for SAP landing zones. It is compatible with the scenario 200. 
# The main differences are the removal of diagnostics settings in the services and advanced directory settings
#
# This configuration is compatible with AIRS, PAYG and EA subscriptions
#

level = "level0"

random_length = 5


launchpad_mode = "launchpad"

# Default region. When not set to a resource it will use that value
default_region = "region1"

regions = {
  region1 = "southeastasia"
  region2 = "eastasia"
}

launchpad_key_names = {
  keyvault               = "launchpad"
  azuread_app            = "caf_launchpad_level0"
  keyvault_client_secret = "aadapp-caf-launchpad-level0"
  tfstates = [
    "level0",
  ]
}

resource_groups = {
  tfstate = {
    name   = "launchpad-tfstates"
    region = "region1"
  }
  security = {
    name = "launchpad-security"
  }
  networking = {
    name = "launchpad-networking"
  }
  bastion_launchpad = {
    name = "launchpad-bastion"
  }
  ops = {
    name = "operations"
  }
  siem = {
    name = "siem-logs"
  }
}

storage_accounts = {
  level0 = {
    name                     = "level0"
    resource_group_key       = "tfstate"
    account_kind             = "BlobStorage"
    account_tier             = "Standard"
    account_replication_type = "RAGRS"
    tags = {
      ## Those tags must never be changed after being set as they are used by the rover to locate the launchpad and the tfstates.
      # Only adjust the environment value at creation time
      tfstate     = "level0"
      environment = "sandpit"
      launchpad   = "launchpad"
      ##
    }
    containers = {
      tfstate = {
        name = "tfstate"
      }
    }
  }

}



keyvaults = {
  # Do not rename the key "launchpad" to be able to upgrade to the standard launchpad
  launchpad = {
    name                = "launchpad"
    resource_group_key  = "security"
    region              = "region1"
    sku_name            = "standard"
    soft_delete_enabled = true
    tags = {
      tfstate     = "level0"
      environment = "sandpit"
    }

  }

  secrets = {
    name                = "secrets"
    resource_group_key  = "security"
    region              = "region1"
    sku_name            = "premium"
    soft_delete_enabled = true

  }
}

keyvault_access_policies = {
  # A maximum of 16 access policies per keyvault
  launchpad = {
    logged_in_user = {
      # if the key is set to "logged_in_user" add the user running terraform in the keyvault policy
      # More examples in /examples/keyvault
      secret_permissions = ["Set", "Get", "List", "Delete", "Purge", "Recover"]
    }
    caf_launchpad_level0 = {
      azuread_app_key    = "caf_launchpad_level0"
      secret_permissions = ["Set", "Get", "List", "Delete", "Purge", "Recover"]
    }
  }

  # A maximum of 16 access policies per keyvault
  secrets = {
    logged_in_user = {
      # if the key is set to "logged_in_user" add the user running terraform in the keyvault policy
      # More examples in /examples/keyvault
      secret_permissions = ["Set", "Get", "List", "Delete", "Purge", "Recover"]
    }
    caf_launchpad_level0 = {
      azuread_app_key    = "caf_launchpad_level0"
      secret_permissions = ["Set", "Get", "List", "Delete", "Purge", "Recover"]
    }
  }

}

azuread_apps = {
  # Do not rename the key "launchpad" to be able to upgrade to the standard launchpad
  caf_launchpad_level0 = {
    useprefix               = true
    application_name        = "caf_launchpad_level0"
    password_expire_in_days = 180

    # Store the ${secret_prefix}-client-id, ${secret_prefix}-client-secret...
    # Set the policy during the creation process of the launchpad
    keyvaults = {
      launchpad = {
        secret_prefix = "aadapp-caf-launchpad-level0"
      }
    }
  }

}

managed_identities = {
  level0 = {
    # Used by the release agent to access the level0 keyvault and storage account with the tfstates in read / write
    name               = "launchpad-level0-msi"
    resource_group_key = "security"
  }
}

#
# Services supported: subscriptions, storage accounts and resource groups
# Can assign roles to: AD groups, AD object ID, AD applications, Managed identities
#

role_mapping = {
  custom_role_mapping = {}
  built_in_role_mapping = {
    storage_accounts = {
      level0 = {
        "Storage Blob Data Contributor" = {
          logged_in = [
            "user"
          ]
          azuread_apps = [
            "caf_launchpad_level0"
          ]
        }
      }
    }
    subscriptions = {
      logged_in_subscription = {
        "Owner" = {
          azuread_apps = [
            "caf_launchpad_level0"
          ]
        }
      }
    }
  }
}


##################################################
#
# Compute resources
#
##################################################

bastion_hosts = {
  launchpad_host = {
    name               = "bastion"
    resource_group_key = "bastion_launchpad"
    vnet_key           = "devops_region1"
    subnet_key         = "AzureBastionSubnet"
    public_ip_key      = "bastion_host_rg1"

  }
}

# Virtual machines
virtual_machines = {

  # Configuration to deploy a bastion host linux virtual machine
  bastion_host = {
    resource_group_key                   = "bastion_launchpad"
    region                               = "region1"
    boot_diagnostics_storage_account_key = "bootdiag_region1"
    provision_vm_agent                   = true

    os_type = "linux"

    # the auto-generated ssh key in keyvault secret. Secret name being {VM name}-ssh-public and {VM name}-ssh-private
    keyvault_key = "secrets"

    # Define the number of networking cards to attach the virtual machine
    networking_interfaces = {
      nic0 = {
        # Value of the keys from networking.tfvars
        networking = {
          vnet_key   = "devops_region1"
          subnet_key = "jumpbox"
        }
        name                    = "0"
        enable_ip_forwarding    = false
        internal_dns_name_label = "nic0"

      }
    }

    virtual_machine_settings = {
      linux = {
        name                            = "bastion"
        size                            = "Standard_F2"
        admin_username                  = "adminuser"
        disable_password_authentication = true
        custom_data                     = "scripts/cloud-init-install-rover-tools.config"

        # Value of the nic keys to attach the VM. The first one in the list is the default nic
        network_interface_keys = ["nic0"]

        os_disk = {
          name                 = "bastion-os"
          caching              = "ReadWrite"
          storage_account_type = "Standard_LRS"
        }

        source_image_reference = {
          publisher = "Canonical"
          offer     = "UbuntuServer"
          sku       = "18.04-LTS"
          version   = "latest"
        }

      }
    }

  }
}

##################################################
#
# Networking resources
#
##################################################


public_ip_addresses = {
  bastion_host_rg1 = {
    name                    = "pip1"
    resource_group_key      = "networking"
    sku                     = "Standard"
    allocation_method       = "Static"
    ip_version              = "IPv4"
    idle_timeout_in_minutes = "4"

  }
}

vnets = {
  devops_region1 = {
    resource_group_key = "networking"
    region             = "region1"
    vnet = {
      name          = "devops"
      address_space = ["10.100.100.0/24"]
    }
    specialsubnets = {}
    subnets = {
      AzureBastionSubnet = {
        name    = "AzureBastionSubnet" #Must be called AzureBastionSubnet
        cidr    = ["10.100.100.24/29"]
        nsg_key = "azure_bastion_nsg"
      }
      jumpbox = {
        name              = "jumpbox"
        cidr              = ["10.100.100.32/29"]
        service_endpoints = ["Microsoft.KeyVault"]
      }
      release_agent_level0 = {
        name              = "level0"
        cidr              = ["10.100.100.40/29"]
        service_endpoints = ["Microsoft.KeyVault"]
      }
      release_agent_level1 = {
        name              = "level1"
        cidr              = ["10.100.100.48/29"]
        service_endpoints = ["Microsoft.KeyVault"]
      }
      release_agent_level2 = {
        name              = "level2"
        cidr              = ["10.100.100.56/29"]
        service_endpoints = ["Microsoft.KeyVault"]
      }
      release_agent_level3 = {
        name              = "level3"
        cidr              = ["10.100.100.64/29"]
        service_endpoints = ["Microsoft.KeyVault"]
      }
      release_agent_level4 = {
        name              = "level4"
        cidr              = ["10.100.100.72/29"]
        service_endpoints = ["Microsoft.KeyVault"]
      }
      private_endpoints = {
        name                                           = "private_endpoints"
        cidr                                           = ["10.100.100.128/25"]
        enforce_private_link_endpoint_network_policies = true
      }
    }

  }
}


route_tables = {
  default_no_internet = {
    name               = "default_no_internet"
    resource_group_key = "networking"
  }
}

azurerm_routes = {
  no_internet = {
    name               = "no_internet"
    resource_group_key = "networking"
    route_table_key    = "default_no_internet"
    address_prefix     = "0.0.0.0/0"
    next_hop_type      = "None"
  }
}


#
# Definition of the networking security groups
#
network_security_group_definition = {
  # This entry is applied to all subnets with no NSG defined
  empty_nsg = {

  }

  azure_bastion_nsg = {

    nsg = [
      {
        name                       = "bastion-in-allow",
        priority                   = "100"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "bastion-control-in-allow-443",
        priority                   = "120"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "135"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
      },
      {
        name                       = "Kerberos-password-change",
        priority                   = "121"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "4443"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
      },
      {
        name                       = "bastion-vnet-out-allow-22",
        priority                   = "103"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "VirtualNetwork"
      },
      {
        name                       = "bastion-vnet-out-allow-3389",
        priority                   = "101"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "VirtualNetwork"
      },
      {
        name                       = "bastion-azure-out-allow",
        priority                   = "120"
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "AzureCloud"
      }
    ]
  }

  jumphost = {

    nsg = [
      {
        name                       = "ssh-inbound-22",
        priority                   = "200"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "VirtualNetwork"
      },
    ]
  }

}


#
# Define the settings for the diagnostics settings
# Demonstrate how to log diagnostics in the correct region
# Different profiles to target different operational teams
#
diagnostics_definition = {
  default_all = {
    name = "operational_logs_and_metrics"
    categories = {
      log = [
        # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
        ["AuditEvent", true, false, 7],
      ]
      metric = [
        #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
        ["AllMetrics", true, false, 7],
      ]
    }
  }

  azurerm_firewall = {
    name = "operational_logs_and_metrics"
    categories = {
      log = [
        #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period] 
        ["AzureFirewallApplicationRule", true, true, 7],
        ["AzureFirewallNetworkRule", true, true, 7],
        ["AzureFirewallDnsProxy", true, true, 7],
      ]
      metric = [
        ["AllMetrics", true, true, 7],
      ]
    }
  }

  public_ip_address = {
    name = "operational_logs_and_metrics"
    categories = {
      log = [
        #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period] 
        ["DDoSProtectionNotifications", true, true, 7],
        ["DDoSMitigationFlowLogs", true, true, 7],
        ["DDoSMitigationReports", true, true, 7],
      ]
      metric = [
        ["AllMetrics", true, true, 7],
      ]
    }
  }

  network_security_group = {
    name = "operational_logs_and_metrics"
    categories = {
      log = [
        # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
        ["NetworkSecurityGroupEvent", true, false, 7],
        ["NetworkSecurityGroupRuleCounter", true, false, 7],
      ]
    }

  }
}

diagnostics_destinations = {
  # Storage keys must reference the azure region name
  storage = {
    all_regions = {
      southeastasia = {
        storage_account_key = "diagsiem_region1"
      }
    }
  }

  log_analytics = {
    central_logs = {
      log_analytics_key              = "central_logs_region1"
      log_analytics_destination_type = "Dedicated"
    }
  }
}


diagnostic_storage_accounts = {
  # Stores diagnostic logging for region1
  diaglogs_region1 = {
    name                     = "diaglogsrg1"
    region                   = "region1"
    resource_group_key       = "ops"
    account_kind             = "BlobStorage"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    access_tier              = "Cool"
  }
  # Stores security logs for siem default region"
  diagsiem_region1 = {
    name                     = "siemsg1"
    resource_group_key       = "siem"
    account_kind             = "BlobStorage"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    access_tier              = "Cool"
  }
}


#
# Define the settings for log analytics workspace and solution map
#
log_analytics = {
  central_logs_region1 = {
    region             = "region1"
    name               = "logs"
    resource_group_key = "ops"
    # you can setup up to 5 key
    # diagnostic_profiles = {
    #   central_logs_region1 = {
    #     definition_key   = "log_analytics"
    #     destination_type = "log_analytics"
    #     destination_key  = "central_logs"
    #   }
    # }
    solutions_maps = {
      NetworkMonitoring = {
        "publisher" = "Microsoft"
        "product"   = "OMSGallery/NetworkMonitoring"
      },
      ADAssessment = {
        "publisher" = "Microsoft"
        "product"   = "OMSGallery/ADAssessment"
      },
      ADReplication = {
        "publisher" = "Microsoft"
        "product"   = "OMSGallery/ADReplication"
      },
      AgentHealthAssessment = {
        "publisher" = "Microsoft"
        "product"   = "OMSGallery/AgentHealthAssessment"
      },
      DnsAnalytics = {
        "publisher" = "Microsoft"
        "product"   = "OMSGallery/DnsAnalytics"
      },
      ContainerInsights = {
        "publisher" = "Microsoft"
        "product"   = "OMSGallery/ContainerInsights"
      },
      KeyVaultAnalytics = {
        "publisher" = "Microsoft"
        "product"   = "OMSGallery/KeyVaultAnalytics"
      }
    }
  }
}