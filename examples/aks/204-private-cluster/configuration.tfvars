landingzone_name = "aks_private_cluster"

tfstates = {
  caf_foundations = {
    tfstate = "caf_foundations.tfstate"
  }
  networking = {
    tfstate = "204-private-cluster_landingzone_networking.tfstate"
  }
}

resource_groups = {
  aks1_rg1 = {
    name   = "aks-rg1"
    region = "region1"
  }
  aks_jumpbox_rg1 = {
    name = "aks-jumpbox-rg1"
  }
}

storage_accounts = {
  bootdiag_re1 = {
    name                     = "bootdiag"
    resource_group_key       = "aks_jumpbox_rg1"
    account_kind             = "BlobStorage"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    access_tier              = "Cool"
  }
}

keyvaults = {
  secrets = {
    name                = "secrets"
    resource_group_key  = "aks_jumpbox_rg1"
    convention          = "cafrandom"
    sku_name            = "premium"
    soft_delete_enabled = true

    # you can setup up to 5 profiles
    diagnostic_profiles = {
      operations = {
        definition_key   = "default_all"
        destination_type = "log_analytics"
        destination_key  = "central_logs"
      }
    }

  }
}

keyvault_access_policies = {
  secrets = {
    logged_in_user = {
      secret_permissions = ["Set", "Get", "List", "Delete", "Purge", "Recover"]
    }
    logged_in_aad_app = {
      secret_permissions = ["Set", "Get", "List", "Delete", "Purge", "Recover"]
    }
    aks_admins = {
      azuread_group_key  = "aks_admins"
      secret_permissions = ["Get", "List"]
    }
  }
}


azure_container_registries = {
  acr1 = {
    name               = "acr-test"
    resource_group_key = "aks1_rg1"
    sku                = "Premium"
    diagnostic_profiles = {
      operations = {
        name             = "operations"
        definition_key   = "azure_container_registry"
        destination_type = "log_analytics"
        destination_key  = "central_logs"
      }
    }
    # georeplication_region_keys = ["region2"]

    private_endpoints = {
      # Require enforce_private_link_endpoint_network_policies set to true on the subnet
      spoke_aks_rg1-aks_nodepool_system = {
        name               = "acr-test-private-link"
        resource_group_key = "aks1_rg1"
        remote_tfstate = {
          tfstate_key = "aks_networking_spoke"
          lz_key      = "aks_networking_spoke"
          output_key  = "vnets"
          vnet_key    = "spoke_aks_rg1"
          subnet_key  = "private_endpoints"
        }
        private_service_connection = {
          name                 = "acr-test-private-link-psc"
          is_manual_connection = false
          subresource_names    = ["registry"]
        }
      }
    }

    # you can setup up to 5 key
    diagnostic_profiles = {
      central_logs_region1 = {
        definition_key   = "azure_container_registry"
        destination_type = "log_analytics"
        destination_key  = "central_logs"
      }
    }
  }
}

aks_clusters = {
  seacluster = {
    name               = "akscluster-001"
    resource_group_key = "aks1_rg1"
    os_type            = "Linux"
    diagnostic_profiles = {
      operations = {
        name             = "aksoperations"
        definition_key   = "azure_kubernetes_cluster"
        destination_type = "log_analytics"
        destination_key  = "central_logs"
      }
    }
    identity = {
      type = "SystemAssigned"
    }

    kubernetes_version = "1.17.11"

    networking = {
      remote_tfstate = {
        tfstate_key = "aks_networking_spoke"
        output_key  = "vnets"
        lz_key      = "aks_networking_spoke"
        vnet_key    = "spoke_aks_rg1"
      }
    }

    network_policy = {
      network_plugin    = "azure"
      load_balancer_sku = "Standard"
    }

    private_cluster_enabled = true
    enable_rbac             = true
    outbound_type           = "userDefinedRouting"

    admin_groups = {
      # ids = []
      azuread_group_keys = [] #["aks_admins"]
    }

    load_balancer_profile = {
      # Only one option can be set
      managed_outbound_ip_count = 1
      # outbound_ip_prefix_ids = []
      # outbound_ip_address_ids = []
    }

    default_node_pool = {
      name                  = "sharedsvc"
      vm_size               = "Standard_F4s_v2"
      subnet_key            = "aks_nodepool_system"
      enabled_auto_scaling  = false
      enable_node_public_ip = false
      max_pods              = 30
      node_count            = 2
      os_disk_size_gb       = 512
      orchestrator_version  = "1.17.11"
      tags = {
        "project" = "system services"
      }
    }

    node_resource_group_name = "aks-nodes-rg1"

    node_pools = {
      pool1 = {
        name                 = "nodepool1"
        mode                 = "User"
        subnet_key           = "aks_nodepool_user1"
        max_pods             = 30
        vm_size              = "Standard_DS2_v2"
        node_count           = 2
        enable_auto_scaling  = false
        os_disk_size_gb      = 512
        orchestrator_version = "1.17.11"
        tags = {
          "project" = "user services"
        }
      }
    }

  }
}

# Virtual machines
virtual_machines = {

  # Configuration to deploy a bastion host linux virtual machine
  bastion_host = {
    resource_group_key                   = "aks_jumpbox_rg1"
    boot_diagnostics_storage_account_key = "bootdiag_re1"
    provision_vm_agent                   = true

    os_type = "linux"

    # the auto-generated ssh key in keyvault secret. Secret name being {VM name}-ssh-public and {VM name}-ssh-private
    keyvault_key = "secrets"

    # Define the number of networking cards to attach the virtual machine
    networking_interfaces = {
      nic0 = {
        # AKS rely on a remote network and need the details of the tfstate to connect (tfstate_key), assuming RBAC authorization.
        networking = {
          remote_tfstate = {
            tfstate_key = "aks_networking_spoke"
            output_key  = "vnets"
            lz_key      = "aks_networking_spoke"
            vnet_key    = "spoke_aks_rg1"
            subnet_key  = "jumpbox"
          }
        }
        name                    = "0"
        enable_ip_forwarding    = false
        internal_dns_name_label = "nic0"

        # you can setup up to 5 profiles
        diagnostic_profiles = {
          operations = {
            definition_key   = "nic"
            destination_type = "log_analytics"
            destination_key  = "central_logs"
          }
        }

      }
    }

    virtual_machine_settings = {
      linux = {
        name                            = "jumpbox"
        size                            = "Standard_DS1_v2"
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

        identity = {
          type = "UserAssigned"
          managed_identity_keys = [
            "jumpbox"
          ]
        }

      }
    }

  }
}

#
# IAM
#

managed_identities = {
  jumpbox = {
    name               = "aks-jumpbox"
    resource_group_key = "aks_jumpbox_rg1"
  }
}

# azuread_groups = {
#   aks_admins = {
#     name        = "aks-admins"
#     description = "Provide access to the AKS cluster and the jumpbox Keyvault secret."
#     members = {
#       user_principal_names = [
#       ]
#       group_names = []
#       object_ids  = []
#       group_keys  = []

#       service_principal_keys = [
#       ]
#     }
#     prevent_duplicate_name = false
#   }
# }


#
# Services supported: subscriptions, storage accounts and resource groups
# Can assign roles to: AD groups, AD object ID, AD applications, Managed identities
#
role_mapping = {
  custom_role_mapping = {}

  built_in_role_mapping = {
    aks_clusters = {
      seacluster = {
        "Azure Kubernetes Service Cluster Admin Role" = {
          azuread_groups = [
            # "aks_admins"
          ]
          managed_identities = [
            "jumpbox"
          ]
        }
      }
    }
    azure_container_registries = {
      acr1 = {
        "AcrPull" = {
          aks_clusters = [
            "seacluster"
          ]
        }
      }
    }
  }
}