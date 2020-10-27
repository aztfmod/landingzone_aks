terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.28.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.13.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 1.3.0"
    }
  }
  required_version = ">= 0.13"
}



provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "kubernetes" {
  load_config_file = false

  host     = local.host
  username = local.username
  password = local.password

  client_certificate     = local.client_certificate
  client_key             = local.client_key
  cluster_ca_certificate = local.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    load_config_file = false

    host     = local.host
    username = local.username
    password = local.password

    client_certificate     = local.client_certificate
    client_key             = local.client_key
    cluster_ca_certificate = local.cluster_ca_certificate
  }
}


data "terraform_remote_state" "aks" {
  backend = "azurerm"
  config = {
    storage_account_name = var.lowerlevel_storage_account_name
    container_name       = var.lowerlevel_container_name
    key                  = var.remote_tfstate
    resource_group_name  = var.lowerlevel_resource_group_name
  }
}

locals {
  landingzone_tag = {
    "landingzone" = "aks" //basename(abspath(path.module))
  }
  tags = merge(var.tags, { "level" = var.level }, { "environment" = var.environment }, { "rover_version" = var.rover_version })


  tfstates = merge(
    map(var.landingzone_name,
      map(
        "storage_account_name", var.tfstate_storage_account_name,
        "container_name", var.tfstate_container_name,
        "resource_group_name", var.tfstate_resource_group_name,
        "key", var.tfstate_key,
        "level", var.level,
        "tenant_id", data.azurerm_client_config.current.tenant_id,
        "subscription_id", data.azurerm_client_config.current.subscription_id
      )
    )
    ,
    data.terraform_remote_state.aks.outputs.tfstates
  )

  cluster = data.terraform_remote_state.aks.outputs.aks_clusters[var.cluster_key]

  host                   = local.cluster.enable_rbac ? local.cluster.kube_admin_config.0.host : local.cluster.kube_config.0.host
  username               = local.cluster.enable_rbac ? local.cluster.kube_admin_config.0.username : local.cluster.kube_config.0.username
  password               = local.cluster.enable_rbac ? local.cluster.kube_admin_config.0.password : local.cluster.kube_config.0.password
  client_certificate     = local.cluster.enable_rbac ? base64decode(local.cluster.kube_admin_config.0.client_certificate) : base64decode(local.cluster.kube_config.0.client_certificate)
  client_key             = local.cluster.enable_rbac ? base64decode(local.cluster.kube_admin_config.0.client_key) : base64decode(local.cluster.kube_config.0.client_key)
  cluster_ca_certificate = local.cluster.enable_rbac ? base64decode(local.cluster.kube_admin_config.0.cluster_ca_certificate) : base64decode(local.cluster.kube_config.0.cluster_ca_certificate)

}









data "azurerm_client_config" "current" {}

# data "terraform_remote_state" "caf_foundations" {
#   backend = "azurerm"
#   config = {
#     storage_account_name = var.lowerlevel_storage_account_name
#     container_name       = var.lowerlevel_container_name
#     key                  = var.tfstates.caf_foundations.tfstate
#     resource_group_name  = var.lowerlevel_resource_group_name
#   }
# }

# data "terraform_remote_state" "networking" {
#   backend = "azurerm"
#   config = {
#     storage_account_name = var.lowerlevel_storage_account_name
#     container_name       = var.lowerlevel_container_name
#     key                  = var.tfstates.networking.tfstate
#     resource_group_name  = var.lowerlevel_resource_group_name
#   }
# }
