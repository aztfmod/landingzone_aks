landingzone = {
  backend_type        = "azurerm"
  level               = "level3"
  key                 = "cluster_aks"
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
  aks_re2 = {
    name   = "aks-re2"
    region = "region2"
  }
}

azure_container_registries = {
  acr1 = {
    name               = "acr-test"
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