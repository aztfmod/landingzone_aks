landingzone = {
  backend_type = "azurerm"
  current = {
    level = "level2"
    key   = "networking_aks"
  }
  lower = {
    foundations = {
      tfstate = "caf_foundations.tfstate"
    }
    networking = {
      launchpad = {
        tfstate = "caf_foundations.tfstate"
      }

    }
  }
}

resource_groups = {
  vnet_rg1 = {
    name   = "vnet-rg1"
    region = "region1"
  }
}

vnets = {
  spoke_aks_rg1 = {
    resource_group_key = "vnet_rg1"
    vnet = {
      name          = "aks"
      address_space = ["100.64.48.0/22"]
    }
    specialsubnets = {}
    subnets = {
      aks_nodepool_system = {
        name            = "aks_nodepool_system"
        cidr            = ["100.64.48.0/24"]
      }
      aks_nodepool_user1 = {
        name            = "aks_nodepool_user1"
        cidr            = ["100.64.49.0/24"]
      }
    }
  }
}
