landingzone = {
  backend_type        = "azurerm"
  level               = "level3"
  key                 = "101-single-cluster_aks"
  global_settings_key = "shared_services"
  tfstates = {
    shared_services = {
      level   = "lower"
      tfstate = "caf_shared_services.tfstate"
    }
    networking_spoke_aks = {
      tfstate = "networking_spoke_aks.tfstate"
    }
  }
}

resource_groups = {
  aks_re1 = {
    name   = "aks-re1"
    region = "region1"
  }
  aks_nodes_re1 = {
    name   = "aks-nodes-re1"
    region = "region1"
  }
}

aks_clusters = {
  cluster_re1 = {
    helm_keys          = ["flux", "podIdentify"]
    name               = "akscluster-001"
    resource_group_key = "aks_re1"
    os_type            = "Linux"

    identity = {
      type = "SystemAssigned"
    }

    kubernetes_version = "1.17.11"
    lz_key             = "networking_spoke_aks"
    vnet_key           = "spoke_aks_re1"

    network_policy = {
      network_plugin    = "azure"
      load_balancer_sku = "Standard"
    }

    enable_rbac = true

    # admin_groups = {
    #   # ids = []
    #   # azuread_groups = {
    #   #   keys = []
    #   # }
    # }

    load_balancer_profile = {
      # Only one option can be set
      managed_outbound_ip_count = 1
      # outbound_ip_prefix_ids = []
      # outbound_ip_address_ids = []
    }

    default_node_pool = {
      name                  = "sharedsvc"
      vm_size               = "Standard_F4s_v2"
      subnet_key            = "aks_nodepool_user1"
      enabled_auto_scaling  = false
      enable_node_public_ip = false
      max_pods              = 30
      node_count            = 1
      os_disk_size_gb       = 512
      orchestrator_version  = "1.17.11"
      tags = {
        "project" = "system services"
      }
    }

    node_resource_group_name = "aks_nodes_re1"
  }
}

azure_container_registries = {
  acr1 = {
    name               = "acr"
    resource_group_key = "aks_re1"
    sku                = "Premium"
    # georeplication_region_keys = ["region2"]

    # you can setup up to 5 key
    # diagnostic_profiles = {
    #   central_logs_region1 = {
    #     definition_key   = "azure_container_registry"
    #     destination_type = "log_analytics"
    #     destination_key  = "central_logs"
    #   }
    # }
  }
}

#
role_mapping = {
  custom_role_mapping = {}

  built_in_role_mapping = {
    azure_container_registries = {
      acr1 = {
        "AcrPull" = {
          aks_clusters = {
            keys = ["cluster_re1"]
          }
        }
      }
    }
  }
}