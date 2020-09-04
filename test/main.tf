variable role_mapping {
  default = {
    built_in_role_mapping = {
      storage_accounts = {
        level0 = {
          "Storage Blob Data Contributor" = {
            logged_in = [
              "app"
            ]
            object_ids = [
              "1111", "2222"
            ]
            azuread_groups = [
              "keyvault_level0_rw"
            ]
            azuread_apps = [
              "caf_launchpad_level0"
            ]
            managed_identities = [
              "level0"
            ]
          }
        }
      }
      subscriptions = {
        logged_in_subscription = {
          "Owner" = {
            azuread_apps = [
              "caf_launchpad_level0"
            ]
          }
        }
      }
    }
  #   custom_role_mapping = {
  #     subscription_keys = {
  #       logged_in_subscription = {
  #         "caf-launchpad-contributor" = {
  #           azuread_group_keys = [
  #             "keyvault_level0_rw", "keyvault_level1_rw", "keyvault_level2_rw", "keyvault_level3_rw", "keyvault_level4_rw",
  #           ]
  #           managed_identity_keys = [
  #             "level0", "level1", "level2", "level3", "level4"
  #           ]
  #         }
  #       }
  #     }
  #   }

  #   built_in_role_mapping = {
  #     aks_clusters = {
  #       seacluster = {
  #         "Azure Kubernetes Service Cluster Admin Role" = {
  #           azuread_group_keys = [
  #             "aks_admins"
  #           ]
  #           managed_identity_keys = [
  #             "jumpbox"
  #           ]
  #         }
  #       }
  #     }
  #     azure_container_registries = {
  #       acr1 = {
  #         "AcrPull" = {
  #           aks_cluster_keys = [
  #             "seacluster"
  #           ]
  #         }
  #       }
  #     }
  #     storage_account_keys = {
  #       level0 = {
  #         "Storage Blob Data Contributor" = {
  #           logged_in_keys = [
  #             "user", "app"
  #           ]
  #           object_ids = [
  #             "232134243242342", "1111111"
  #           ]
  #           azuread_group_keys = [
  #             "keyvault_level0_rw"
  #           ]
  #           azuread_app_keys = [
  #             "caf_launchpad_level0"
  #           ]
  #           managed_identity_keys = [
  #             "level0"
  #           ]
  #         }
  #       }
  #       level1 = {
  #         "Storage Blob Data Contributor" = {
  #           azuread_group_keys = [
  #             "keyvault_level1_rw"
  #           ]
  #           managed_identity_keys = [
  #             "level1"
  #           ]
  #         }
  #       }
  #       level2 = {
  #         "Storage Blob Data Contributor" = {
  #           azuread_group_keys = [
  #             "keyvault_level2_rw"
  #           ]
  #           managed_identity_keys = [
  #             "level2"
  #           ]
  #         }
  #       }
  #       level3 = {
  #         "Storage Blob Data Contributor" = {
  #           azuread_group_keys = [
  #             "keyvault_level3_rw"
  #           ]
  #           managed_identity_keys = [
  #             "level3"
  #           ]
  #         }
  #       }
  #       level4 = {
  #         "Storage Blob Data Contributor" = {
  #           azuread_group_keys = [
  #             "keyvault_level4_rw"
  #           ]
  #           managed_identity_keys = [
  #             "level4"
  #           ]
  #         }
  #       }
  #     }
  #   }
  }
}

locals {
  built_in_roles = {
    for mapping in
    flatten(
      [
        for key_mode, all_role_mapping in var.role_mapping : [
          for key, role_mappings in all_role_mapping : [
            for scope_key_resource, role_mapping in role_mappings : [
              for role_definition_name, resources in role_mapping : [
                for object_id_key, object_resources in resources : [
                  for object_id_key_resource in object_resources :
                  {
                    mode               = key_mode
                    scope_resource_key = key
                    # resources               = resources
                    object_id_resource_type = object_id_key
                    scope_key_resource      = scope_key_resource
                    role_definition_name    = role_definition_name
                    object_id_key_resource  = object_id_key_resource
                  }
                ]
              ]
            ]
          ]
        ]
      ]
    ) : format("%s_%s_%s", mapping.scope_key_resource, replace(mapping.role_definition_name, " ", "_"), mapping.object_id_key_resource) => mapping
  }

  # services_roles = {
  #   aks_clusters               = module.aks_clusters
  #   azure_container_registries = module.container_registry
  #   azuread_groups             = module.azuread_groups
  #   azuread_apps               = module.azuread_applications
  #   managed_identities         = azurerm_user_assigned_identity.msi
  #   subscriptions              = merge(try(var.subscriptions, {}), { "logged_in_subscription" = data.azurerm_subscription.primary.id })
  #   logged_in = {
  #     user = local.client_config.logged_user_objectId
  #     app  = local.client_config.logged_aad_app_objectId
  #   }
  # }
}


output built_in_roles {
  value = local.built_in_roles
}

output number_of_roles {
  value = length(local.built_in_roles)
}


## Generates a trnaformed structure
# built_in_roles = {
#   "acr1_AcrPull_seacluster" = {
#     "mode" = "built_in_role_mapping"
#     "object_id_key_resource" = "seacluster"
#     "object_id_resource_type" = "aks_cluster_keys"
#     "role_definition_name" = "AcrPull"
#     "scope_key_resource" = "acr1"
#     "scope_resource_key" = "azure_container_registries"
#   }
#   "logged_in_subscription_caf-launchpad-contributor_keyvault_level0_rw" = {
#     "mode" = "custom_role_mapping"
#     "object_id_key_resource" = "keyvault_level0_rw"
#     "object_id_resource_type" = "azuread_group_keys"
#     "role_definition_name" = "caf-launchpad-contributor"
#     "scope_key_resource" = "logged_in_subscription"
#     "scope_resource_key" = "subscription_keys"
#   }
#   "logged_in_subscription_caf-launchpad-contributor_keyvault_level1_rw" = {
#     "mode" = "custom_role_mapping"
#     "object_id_key_resource" = "keyvault_level1_rw"
#     "object_id_resource_type" = "azuread_group_keys"
#     "role_definition_name" = "caf-launchpad-contributor"
#     "scope_key_resource" = "logged_in_subscription"
#     "scope_resource_key" = "subscription_keys"
#   }
#   "logged_in_subscription_caf-launchpad-contributor_keyvault_level2_rw" = {
#     "mode" = "custom_role_mapping"
#     "object_id_key_resource" = "keyvault_level2_rw"
#     "object_id_resource_type" = "azuread_group_keys"
#     "role_definition_name" = "caf-launchpad-contributor"
#     "scope_key_resource" = "logged_in_subscription"
#     "scope_resource_key" = "subscription_keys"
#   }
#   "logged_in_subscription_caf-launchpad-contributor_keyvault_level3_rw" = {
#     "mode" = "custom_role_mapping"
#     "object_id_key_resource" = "keyvault_level3_rw"
#     "object_id_resource_type" = "azuread_group_keys"
#     "role_definition_name" = "caf-launchpad-contributor"
#     "scope_key_resource" = "logged_in_subscription"
#     "scope_resource_key" = "subscription_keys"
#   }
#   "logged_in_subscription_caf-launchpad-contributor_keyvault_level4_rw" = {
#     "mode" = "custom_role_mapping"
#     "object_id_key_resource" = "keyvault_level4_rw"
#     "object_id_resource_type" = "azuread_group_keys"
#     "role_definition_name" = "caf-launchpad-contributor"
#     "scope_key_resource" = "logged_in_subscription"
#     "scope_resource_key" = "subscription_keys"
#   }
#   "logged_in_subscription_caf-launchpad-contributor_level0" = {
#     "mode" = "custom_role_mapping"
#     "object_id_key_resource" = "level0"
#     "object_id_resource_type" = "azuread_group_keys"
#     "role_definition_name" = "caf-launchpad-contributor"
#     "scope_key_resource" = "logged_in_subscription"
#     "scope_resource_key" = "subscription_keys"
#   }
#   "logged_in_subscription_caf-launchpad-contributor_level1" = {
#     "mode" = "custom_role_mapping"
#     "object_id_key_resource" = "level1"
#     "object_id_resource_type" = "azuread_group_keys"
#     "role_definition_name" = "caf-launchpad-contributor"
#     "scope_key_resource" = "logged_in_subscription"
#     "scope_resource_key" = "subscription_keys"
#   }
#   "logged_in_subscription_caf-launchpad-contributor_level2" = {
#     "mode" = "custom_role_mapping"
#     "object_id_key_resource" = "level2"
#     "object_id_resource_type" = "azuread_group_keys"
#     "role_definition_name" = "caf-launchpad-contributor"
#     "scope_key_resource" = "logged_in_subscription"
#     "scope_resource_key" = "subscription_keys"
#   }
#   "logged_in_subscription_caf-launchpad-contributor_level3" = {
#     "mode" = "custom_role_mapping"
#     "object_id_key_resource" = "level3"
#     "object_id_resource_type" = "azuread_group_keys"
#     "role_definition_name" = "caf-launchpad-contributor"
#     "scope_key_resource" = "logged_in_subscription"
#     "scope_resource_key" = "subscription_keys"
#   }
#   "logged_in_subscription_caf-launchpad-contributor_level4" = {
#     "mode" = "custom_role_mapping"
#     "object_id_key_resource" = "level4"
#     "object_id_resource_type" = "azuread_group_keys"
#     "role_definition_name" = "caf-launchpad-contributor"
#     "scope_key_resource" = "logged_in_subscription"
#     "scope_resource_key" = "subscription_keys"
#   }
#   "seacluster_Azure_Kubernetes_Service_Cluster_Admin_Role_aks_admins" = {
#     "mode" = "built_in_role_mapping"
#     "object_id_key_resource" = "aks_admins"
#     "object_id_resource_type" = "azuread_group_keys"
#     "role_definition_name" = "Azure Kubernetes Service Cluster Admin Role"
#     "scope_key_resource" = "seacluster"
#     "scope_resource_key" = "aks_clusters"
#   }
#   "seacluster_Azure_Kubernetes_Service_Cluster_Admin_Role_jumpbox" = {
#     "mode" = "built_in_role_mapping"
#     "object_id_key_resource" = "jumpbox"
#     "object_id_resource_type" = "azuread_group_keys"
#     "role_definition_name" = "Azure Kubernetes Service Cluster Admin Role"
#     "scope_key_resource" = "seacluster"
#     "scope_resource_key" = "aks_clusters"
#   }
# }