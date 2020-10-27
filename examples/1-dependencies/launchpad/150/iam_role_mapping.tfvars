
#
# Services supported: subscriptions, storage accounts and resource groups
# Can assign roles to: AD groups, AD object ID, AD applications, Managed identities
#
role_mapping = {

  built_in_role_mapping = {
    subscriptions = {
      logged_in_subscription = {
        "Contributor" = {
          managed_identities = {
            keys = ["level0", "level1", "level2", "level3", "level4"]
          }
        }
      }
    }
    storage_accounts = {
      level0 = {
        "Storage Blob Data Contributor" = {
          logged_in = {
            keys = ["user"]
          }
          managed_identities = {
            keys = ["level0"]
          }
        }
      }
      level1 = {
        "Storage Blob Data Contributor" = {
          logged_in = {
            keys = ["user"]
          }
          managed_identities = {
            keys = ["level1"]
          }
        }
      }
      level2 = {
        "Storage Blob Data Contributor" = {
          logged_in = {
            keys = ["user"]
          }
          managed_identities = {
            keys = ["level2"]
          }
        }
      }
      level3 = {
        "Storage Blob Data Contributor" = {
          logged_in = {
            keys = ["user"]
          }
          managed_identities = {
            keys = ["level3"]
          }
        }
      }
    }
  }

}
