tags       = {}
convention = "cafrandom"

resource_groups = {
  aks1 = {
    name       = "aks-1"
    region   = "region1"
    useprefix  = true
    max_length = 40
  }
  aks2 = {
    name       = "aks-2"
    region   = "region2"
    useprefix  = true
    max_length = 40
  }
}

registries = {
  registry1 = {
    name                = "acr001"
    resource_group_key  = "aks1"
    sku                      = "Premium"
    admin_enabled            = false
    private_endpoint_subnet_keys = ["aks_nodepool_system","aks_nodepool_system1"]
  }
  registry2 = {
    name                = "acr002"
    resource_group_key  = "aks2"
    sku                      = "Premium"
    admin_enabled            = false
  }
}

clusters = {
  cluster1 = {
    name                = "cluster-001"
    resource_group_key = "aks1"
    os_type             = "Linux"
    identity = {
      type = "SystemAssigned"
    }
    acr_keys = {
      registry1 = "registry1"
      registry2 = "registry2"
    }
    kubernetes_version = "1.15.12"
    vnet_key           = "spoke_aks_sg"
    network_policy = {
      network_plugin    = "azure"
      load_balancer_sku = "Standard"
    }
    enable_rbac = true

    load_balancer_profile = {
      # Only one option can be set
      managed_outbound_ip_count = 1
      # outbound_ip_prefix_ids = []
      # outbound_ip_address_ids = []
    }

    default_node_pool = {
      name                  = "sharedsvc"
      vm_size               = "Standard_F4s_v2"
      subnet_key           = "aks_nodepool_system"
      availability_zones    = ["1"]
      enabled_auto_scaling  = false
      enable_node_public_ip = false
      max_pods              = 30
      node_count            = 1
      os_disk_size_gb       = 64
      orchestrator_version  = "1.15.11"
      tags = {
        "project" = "shared services"
      }
    }

    node_pools = {
      systempool1 = {
        name                 = "systempool1"
        mode                 = "System"
        subnet_key          = "aks_nodepool_system1"
        max_pods             = 30
        vm_size              = "Standard_DS2_v2"
        node_count           = 3
        enable_auto_scaling  = false
        os_disk_size_gb      = 64
        orchestrator_version = "1.15.11"
      }
      userpool1 = {
        name                 = "userpool1"
        mode                 = "User"
        subnet_key          = "aks_nodepool_user1"
        max_pods             = 10
        vm_size              = "Standard_DS2_v2"
        node_count           = 1
        enable_auto_scaling  = false
        availability_zones   = ["1"]
        os_disk_size_gb      = 64
        orchestrator_version = "1.15.11"
      }
    }
  }
  cluster2 = {
    name                = "cluster-001"
    resource_group_key = "aks2"
    os_type             = "Linux"
    identity = {
      type = "SystemAssigned"
    }
    kubernetes_version = "1.15.12"
    vnet_key           = "spoke_aks_ea"

    acr_keys = {
      registry2 = "registry2"
    }
    network_policy = {
      network_plugin    = "azure"
      load_balancer_sku = "Standard"

    }
    enable_rbac = true

    load_balancer_profile = {
      # Only one option can be set
      managed_outbound_ip_count = 1
      # outbound_ip_prefix_ids = []
      # outbound_ip_address_ids = []
    }

    default_node_pool = {
      name                  = "sharedsvc"
      vm_size               = "Standard_F4s_v2"
      subnet_key           = "aks_nodepool_system"
      enabled_auto_scaling  = false
      enable_node_public_ip = false
      max_pods              = 30
      node_count            = 1
      os_disk_size_gb       = 64
      orchestrator_version  = "1.15.11"
      tags = {
        "project" = "shared services"
      }
    }

    node_pools = {
      systempool1 = {
        name                 = "systempool1"
        mode                 = "System"
        subnet_key          = "aks_nodepool_system1"
        max_pods             = 30
        vm_size              = "Standard_DS2_v2"
        node_count           = 3
        enable_auto_scaling  = false
        os_disk_size_gb      = 64
        orchestrator_version = "1.15.11"
      }
      userpool1 = {
        name                 = "userpool1"
        mode                 = "User"
        subnet_key          = "aks_nodepool_user1"
        max_pods             = 10
        vm_size              = "Standard_DS2_v2"
        node_count           = 1
        enable_auto_scaling  = false
        os_disk_size_gb      = 64
        orchestrator_version = "1.15.11"
      }
    }
  }
}

jumpboxes = {
  ubuntu1 = {
    name = "ubuntujumpbox"
    resource_group_name = "jumpbox"
    location = "southeastasia"
    os = "Linux"
    vnet_key           = "hub_sg" 
    subnet_key         = "jumpbox"
    storage_image_reference = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      version   = "latest"
    }
    vm_size = "Standard_DS1_v2"
    os_profile = {
        admin_username = "testadmin"
        admin_password = "Ab123456789!"
    }
    storage_os_disk = {
      name              = "ubuntuosdisk1"
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Standard_LRS"
      disk_size_gb      = "128"
    }
  }
}