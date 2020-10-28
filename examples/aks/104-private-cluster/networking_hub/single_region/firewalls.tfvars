azurerm_firewalls = {
  fw_re1 = {
    name               = "egress"
    resource_group_key = "vnet_hub_re1"
    vnet_key           = "hub_re1"
    public_ip_key      = "firewall_re1"

    # you can setup up to 5 keys - vnet diganostic
    # diagnostic_profiles = {
    #   operation = {
    #     definition_key   = "azurerm_firewall"
    #     destination_type = "log_analytics"
    #     destination_key  = "central_logs"
    #   }
    # }

    azurerm_firewall_network_rule_collections = [
      "aks"
    ]

    azurerm_firewall_application_rule_collections = [
      "aks",
      "packages"
    ]
  }
}


azurerm_firewall_network_rule_collection_definition = {
  aks = {
    name     = "aks"
    action   = "Allow"
    priority = 150
    ruleset = {
      ntp = {
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
      monitor = {
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
    }
  }
}

azurerm_firewall_application_rule_collection_definition = {
  aks = {
    name     = "aks"
    action   = "Allow"
    priority = 100
    ruleset = {
      aks = {
        name = "aks"
        source_addresses = [
          "*",
        ]
        fqdn_tags = [
          "AzureKubernetesService",
        ]
      },
    }
  }
  packages = {
    name     = "packages"
    action   = "Allow"
    priority = 110
    ruleset = {
      ubuntu = {
        name = "ubuntu"
        source_addresses = [
          "*",
        ]
        target_fqdns = [
          "security.ubuntu.com",
          "azure.archive.ubuntu.com",
          "archive.ubuntu.com",
          "changelogs.ubuntu.com",
        ]
        protocol = {
          https = {
            port = "443"
            type = "Https"
          }
          http = {
            port = "80"
            type = "Http"
          }
        }
      },
      docker = {
        name = "docker"
        source_addresses = [
          "*",
        ]
        target_fqdns = [
          "download.docker.com", # Docker
          "*.docker.io",         # Docker images
          "*.docker.com"         # Docker registry
        ]
        protocol = {
          http = {
            port = "443"
            type = "Https"
          }
        }
      },
      tools = {
        name = "tools"
        source_addresses = [
          "*",
        ]
        target_fqdns = [
          "packages.microsoft.com",
          "azurecliprod.blob.core.windows.net", # Azure cli
          "packages.cloud.google.com",          # kubectl
          "apt.kubernetes.io",                  # Ubuntu packages for kubectl
          "*.snapcraft.io",                     # snap to install kubectl
        ]
        protocol = {
          http = {
            port = "443"
            type = "Https"
          }
        }
      },
      github = {
        name = "github"
        source_addresses = [
          "*",
        ]
        target_fqdns = [
          "api.github.com",
          "github.com",
          "github-production-release-asset-2e65be.s3.amazonaws.com",
        ]
        protocol = {
          http = {
            port = "443"
            type = "Https"
          }
        }
      },
    }
  }
}