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

    lz_key   = "networking_spoke_aks"
    vnet_key = "spoke_aks_re1"

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
      orchestrator_version  = "1.17.11"
      tags = {
        "project" = "system services"
      }
    }

    node_resource_group_name = "aks-nodes-re1"

    node_pools = {
      pool1 = {
        name                 = "nodepool2"
        mode                 = "User"
        subnet_key           = "aks_nodepool_user1"
        max_pods             = 30
        vm_size              = "Standard_DS2_v2"
        node_count           = 1
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