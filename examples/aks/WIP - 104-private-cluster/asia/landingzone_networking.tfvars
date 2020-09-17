resource_groups = {
  vnet_sg = {
    name       = "vnet-hub-sg"
    location   = "southeastasia"
    useprefix  = true
    max_length = 40
  }
}

vnets = {
  hub_sg = {
    resource_group_key = "vnet_sg"
    location           = "southeastasia"
    vnet = {
      name          = "hub"
      address_space = ["10.10.100.0/24"]
    }
    specialsubnets = {
      AzureFirewallSubnet = {
        name = "AzureFirewallSubnet" #Must be called AzureFirewallSubnet 
        cidr = ["10.10.100.192/26"]
      }
    }
    subnets = {
      jumpbox = {
        name     = "jumpbox"
        cidr     = ["10.10.100.0/27"]
        nsg_name = "jumpbox_nsg"
        nsg      = []
      }
    }
    # Override the default var.diagnostics.vnet
    diagnostics = {
      log = [
        # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period] 
        ["VMProtectionAlerts", true, true, 60],
      ]
      metric = [
        #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]                 
        ["AllMetrics", true, true, 60],
      ]
    }
  }

  spoke_aks_sg = {
    resource_group_key = "vnet_sg"
    location           = "southeastasia"
    vnet = {
      name          = "aks"
      address_space = ["10.20.100.0/23"]
    }
    specialsubnets = {}
    subnets = {
      aks_nodepool_system = {
        name     = "aks_nodepool_system"
        cidr     = ["10.20.100.0/25"]
        nsg_name = "aks_nodepool_system_nsg"
        nsg      = []
      }
      aks_nodepool_system1 = {
        name     = "aks_nodepool_system1"
        cidr     = ["10.20.100.128/25"]
        nsg_name = "aks_nodepool_system1_nsg"
        nsg      = []
      }
      aks_nodepool_user1 = {
        name     = "aks_nodepool_user1"
        cidr     = ["10.20.101.0/25"]
        nsg_name = "aks_nodepool_user1_nsg"
        nsg      = []
      }
    }
  }
}

firewalls = {
  # Southeastasia firewall (do not change the key when created)
  southeastasia = {
    location           = "southeastasia"
    resource_group_key = "vnet_sg"
    vnet_key           = "hub_sg"

    # Settings for the public IP address to be used for Azure Firewall 
    # Must be standard and static for 
    firewall_ip_addr_config = {
      ip_name           = "firewall"
      allocation_method = "Static"
      sku               = "Standard" #defaults to Basic
      ip_version        = "IPv4"     #defaults to IP4, Only dynamic for IPv6, Supported arguments are IPv4 or IPv6, NOT Both
      diagnostics = {
        log = [
          #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period] 
          ["DDoSProtectionNotifications", true, true, 30],
          ["DDoSMitigationFlowLogs", true, true, 30],
          ["DDoSMitigationReports", true, true, 30],
        ]
        metric = [
          ["AllMetrics", true, true, 30],
        ]
      }
    }

    # Settings for the Azure Firewall settings
    az_fw_config = {
      name = "azfw"
      diagnostics = {
        log = [
          #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period] 
          ["AzureFirewallApplicationRule", true, true, 30],
          ["AzureFirewallNetworkRule", true, true, 30],
        ]
        metric = [
          ["AllMetrics", true, true, 30],
        ]
      }
      rules = {
        azurerm_firewall_network_rule_collection = {
          aks = {
            name     = "aks"
            action   = "Allow"
            priority = 150
            ruleset = [
              {
                name = "ntp"
                source_addresses = [
                  "*",
                ]
                destination_ports = [
                  "123",
                ]
                destination_addresses = [
                  "91.189.89.198", "91.189.91.157", "91.189.94.4", "91.189.89.199"
                ]
                protocols = [
                  "UDP",
                ]
              },
              {
                name = "monitor"
                source_addresses = [
                  "*",
                ]
                destination_ports = [
                  "443",
                ]
                destination_addresses = [
                  "AzureMonitor"
                ]
                protocols = [
                  "TCP",
                ]
              },
            ]
          }
        }
        azurerm_firewall_application_rule_collection = {
          aks = {
            name     = "aks"
            action   = "Allow"
            priority = 100
            ruleset = [
              {
                name = "aks"
                source_addresses = [
                  "*",
                ]
                fqdn_tags = [
                  "AzureKubernetesService",
                ]
              },
              {
                name = "ubuntu"
                source_addresses = [
                  "*",
                ]
                target_fqdns = [
                  "security.ubuntu.com", "azure.archive.ubuntu.com", "changelogs.ubuntu.com"
                ]
                protocol = {
                  http = {
                    port = "80"
                    type = "Http"
                  }
                }
              },
            ]
          }
        }
      }
    }

  }

}

peerings = {
  hub_sg_TO_spoke_aks_sg = {
    from_key                     = "hub_sg"
    to_key                       = "spoke_aks_sg"
    name                         = "hub_sg_TO_spoke_aks_sg"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = false
    allow_gateway_transit        = false
    use_remote_gateways          = false
  }

  spoke_aks_sg_TO_hub_sg = {
    from_key                     = "spoke_aks_sg"
    to_key                       = "hub_sg"
    name                         = "spoke_aks_sg_TO_hub_sg"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = false
    allow_gateway_transit        = false
    use_remote_gateways          = false
  }
}

route_tables = {
  from_spoke_to_hub = {
    name               = "spoke_aks_sg_to_hub_sg"
    resource_group_key = "vnet_sg"

    vnet_keys = {
      "spoke_aks_sg" = {
        subnet_keys = ["aks_nodepool_system", "aks_nodepool_user1"]
      }
    }

    route_entries = {
      re1 = {
        name          = "defaultroute"
        prefix        = "0.0.0.0/0"
        next_hop_type = "VirtualAppliance"
        azfw = {
          VirtualAppliance_key = "southeastasia"
          ipconfig_index       = 0
        }
      }
    }
  }
}
