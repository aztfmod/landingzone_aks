tags       = {}
convention = "cafrandom"

resource_groups = {
  aks1 = {
    name       = "aks-1"
    region     = "region1"
    useprefix  = true
    max_length = 40
  }
}

clusters = {
  cluster1 = {
    name               = "cluster-001"
    resource_group_key = "aks1"
    os_type            = "Linux"
    identity = {
      type = "SystemAssigned"
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
      subnet_key            = "aks_nodepool_system"
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
  }
}