landingzone_name = "aks"
tfstates = {
  caf_foundations = {
    tfstate = "caf_foundations.tfstate"
  }
  networking = {
    tfstate = "102-multi-nodepools_landingzone_networking.tfstate"
  }
}

resource_groups = {
  aks_rg1 = {
    name   = "aks-rg1"
    region = "region1"
  }
}

aks_clusters = {
  cluster_rg1 = {
    helm_keys          = ["flux", "podIdentify"]
    name               = "akscluster-001"
    resource_group_key = "aks_rg1"
    os_type            = "Linux"

    identity = {
      type = "SystemAssigned"
    }

    kubernetes_version = "1.17.7"

    networking = {
      remote_tfstate = {
        tfstate_key = "networking_aks"
        output_key  = "vnets"
        lz_key      = "networking_aks"
        vnet_key    = "spoke_aks_rg1"
      }
    }

    network_policy = {
      network_plugin    = "azure"
      load_balancer_sku = "Standard"
    }

    enable_rbac = true

    admin_groups = {
      # ids = []
      azuread_group_keys = []
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
      node_count            = 1
      os_disk_size_gb       = 512
      orchestrator_version  = "1.17.7"
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
        node_count           = 1
        enable_auto_scaling  = false
        os_disk_size_gb      = 512
        orchestrator_version = "1.17.7"
        tags = {
          "project" = "user services"
        }
      }
    }

  }
}

azure_container_registries = {
  acr1 = {
    name               = "acr-test"
    resource_group_key = "aks_rg1"
    sku                = "Premium"
    # georeplication_region_keys = ["region2"]

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

#
role_mapping = {
  custom_role_mapping = {}

  built_in_role_mapping = {
    azure_container_registries = {
      acr1 = {
        "AcrPull" = {
          aks_clusters = [
            "cluster_rg1"
          ]
        }
      }
    }
  }
}