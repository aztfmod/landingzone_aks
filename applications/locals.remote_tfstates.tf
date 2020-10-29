locals {
  landingzone = {
    current = {
      storage_account_name = var.tfstate_storage_account_name
      container_name       = var.tfstate_container_name
      resource_group_name  = var.tfstate_resource_group_name
    }
    lower = {
      storage_account_name = var.lower_storage_account_name
      container_name       = var.lower_container_name
      resource_group_name  = var.lower_resource_group_name
    }
  }
}

data "terraform_remote_state" "remote" {
  for_each = try(var.landingzone.tfstates, {})

  backend = var.landingzone.backend_type
  config = {
    storage_account_name = local.landingzone[try(each.value.level, "current")].storage_account_name
    container_name       = local.landingzone[try(each.value.level, "current")].container_name
    resource_group_name  = local.landingzone[try(each.value.level, "current")].resource_group_name
    key                  = each.value.tfstate
  }
}

locals {
  landingzone_tag = {
    "landingzone" = var.landingzone.key
  }

  tags = merge(var.tags, local.landingzone_tag, { "level" = var.landingzone.level }, { "environment" = local.global_settings.environment }, { "rover_version" = var.rover_version })

  global_settings = data.terraform_remote_state.remote[var.landingzone.global_settings_key].outputs.global_settings

  remote = {
    aks_clusters = {
      for key, value in try(var.landingzone.tfstates, {}) : key => merge(try(data.terraform_remote_state.remote[key].outputs.aks_clusters[key], {}))
    }
  }

  cluster = local.remote.aks_clusters[var.landingzone_key][var.cluster_key]

  host                   = local.cluster.enable_rbac ? local.cluster.kube_admin_config.0.host : local.cluster.kube_config.0.host
  username               = local.cluster.enable_rbac ? local.cluster.kube_admin_config.0.username : local.cluster.kube_config.0.username
  password               = local.cluster.enable_rbac ? local.cluster.kube_admin_config.0.password : local.cluster.kube_config.0.password
  client_certificate     = local.cluster.enable_rbac ? base64decode(local.cluster.kube_admin_config.0.client_certificate) : base64decode(local.cluster.kube_config.0.client_certificate)
  client_key             = local.cluster.enable_rbac ? base64decode(local.cluster.kube_admin_config.0.client_key) : base64decode(local.cluster.kube_config.0.client_key)
  cluster_ca_certificate = local.cluster.enable_rbac ? base64decode(local.cluster.kube_admin_config.0.cluster_ca_certificate) : base64decode(local.cluster.kube_config.0.cluster_ca_certificate)


}
