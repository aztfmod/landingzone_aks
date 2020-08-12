# Sample Cloud Adoption Framework foundations landing zone

## globalsettings
global_settings = {
  #specifies the set of locations you are going to use in this landing zone
  location_map = {
    eastus = "southeastasia"
    westus = "eastasia"
  }

  #naming convention to be used as defined in naming convention module, accepted values are cafclassic, cafrandom, random, passthrough
  convention = "cafrandom"

  #Set of tags for core operations
  tags_hub = {
    owner          = "CAF"
    deploymentType = "Terraform"
  }

  # Set of resource groups to land the foundations
  resource_groups_hub = {
    eastus = {
      HUB-CORE-SEC = {
        name     = "hub-core-sec-eus"
        location = "southeastasia"
      }
      HUB-OPERATIONS = {
        name     = "hub-operations-eus"
        location = "southeastasia"
      }
    }
    westus = {
      HUB-CORE-SEC = {
        name     = "hub-core-sec-wus"
        location = "eastasia"
      }
      HUB-OPERATIONS = {
        name     = "hub-operations-wus"
        location = "eastasia"
      }
    }
  }
}

## accounting settings
accounting_settings = {

  # Azure diagnostics logs retention period
  eastus = {
    # Azure Subscription activity logs retention period
    azure_activity_log_enabled    = false
    azure_activity_logs_name      = "actlogeus"
    azure_activity_logs_event_hub = false
    azure_activity_logs_retention = 31
    azure_activity_audit = {
      log = [
        # ["Audit category name",  "Audit enabled)"] 
        ["Administrative", true],
        ["Security", true],
        ["ServiceHealth", true],
        ["Alert", true],
        ["Recommendation", true],
        ["Policy", true],
        ["Autoscale", true],
        ["ResourceHealth", true],
      ]
    }
    azure_diagnostics_logs_name      = "diaglogs"
    azure_diagnostics_logs_event_hub = false

    #Logging and monitoring 
    analytics_workspace_name = "caflalogs-eus"

    ##Log analytics solutions to be deployed 
    solution_plan_map = {
      KeyVaultAnalytics = {
        "publisher" = "Microsoft"
        "product"   = "OMSGallery/KeyVaultAnalytics"
      }
    }
  }
  westus = {
    # Azure Subscription activity logs retention period
    azure_activity_log_enabled    = false
    azure_activity_logs_name      = "actlogwus"
    azure_activity_logs_event_hub = false
    azure_activity_logs_retention = 31
    azure_activity_audit = {
      log = [
        # ["Audit category name",  "Audit enabled)"] 
        ["Administrative", true],
        ["Security", true],
        ["ServiceHealth", true],
        ["Alert", true],
        ["Recommendation", true],
        ["Policy", true],
        ["Autoscale", true],
        ["ResourceHealth", true],
      ]
    }
    azure_diagnostics_logs_name      = "diaglogs"
    azure_diagnostics_logs_event_hub = false

    #Logging and monitoring 
    analytics_workspace_name = "caflalogs-wus"

    ##Log analytics solutions to be deployed 
    solution_plan_map = {
      KeyVaultAnalytics = {
        "publisher" = "Microsoft"
        "product"   = "OMSGallery/KeyVaultAnalytics"
      }
    }
  }
}


## governance
governance_settings = {
  eastus = {
    #current code supports only two levels of managemenr groups and one root
    deploy_mgmt_groups = false
    management_groups = {}

    policy_matrix = {
      autoenroll_monitor_vm = true
      autoenroll_netwatcher = false

      no_public_ip_spoke     = false
      cant_create_ip_spoke   = false
      managed_disks_only     = true
      restrict_locations     = false
      list_of_allowed_locs   = ["eastus", "westus"]
      restrict_supported_svc = false
      list_of_supported_svc  = ["Microsoft.Network/publicIPAddresses", "Microsoft.Compute/disks"]
      msi_location           = "eastus"
    }
  }

  westus = {}
}

## security 
security_settings = {
  #Azure Security Center Configuration 
  enable_security_center = false
  security_center = {
    contact_email = "email@email.com"
    contact_phone = "9293829328"
  }
  #Enables Azure Sentinel on the Log Analaytics repo
  enable_sentinel = false
}
