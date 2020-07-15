tags = {}
blueprint_aks = {
    convention          = "cafrandom"
    aks_subnet_name     = "aks-system"

    cluster = {
        name                = "akscluster-001"
        location            = "southeastasia"
        resource_group_name = "aks"
        os_type             = "Linux"
        identity            = {
            type = "SystemAssigned"
        }
        kubernetes_version = "1.15.11"

        network_policy = {
            network_plugin      = "azure"
            load_balancer_sku   = "Standard"

        }

        load_balancer_profile = {
            # Only one option can be set
            managed_outbound_ip_count = 1
            # outbound_ip_prefix_ids = []
            # outbound_ip_address_ids = []
        }

        default_node_pool = {
            name                    = "sharedsvc"
            vm_size                 = "Standard_F4s_v2"
            availability_zones      = ["1"]
            enabled_auto_scaling    = false
            enable_node_public_ip   = false
            max_pods                = 30
            node_count              = 1
            os_disk_size_gb         = 64
            tags                    = {
                "project" = "shared services"
            }
        }
    }

    agent_pools = {
        networking = {
            name                    = "network"
            vm_size                 = "Standard_F4s_v2"
            availability_zones      = ["1"]
            enabled_auto_scaling    = false
            enable_node_public_ip   = false
            max_pods                = 60
            os_disk_size_gb         = 64
            tags                    = {}
        }
    }
}