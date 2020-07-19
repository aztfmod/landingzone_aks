terraform {
  backend "azurerm" {
  }
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~>0.4.3"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.17.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 0.10.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.2.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.1.0"
    }
  }

}

provider "azurecaf" {
  alias = "azcaf"
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {}

data "terraform_remote_state" "landingzone_networking" {
  backend = "azurerm"
  config = {
    storage_account_name = var.lowerlevel_storage_account_name
    container_name       = var.workspace
    resource_group_name  = var.lowerlevel_resource_group_name
    key                  = var.tfstate_landingzone_networking
  }
}

data "terraform_remote_state" "landingzone_caf_foundations" {
  backend = "azurerm"
  config = {
    storage_account_name = var.lowerlevel_storage_account_name
    container_name       = var.workspace
    resource_group_name  = var.lowerlevel_resource_group_name
    key                  = var.tfstate_landingzone_caf_foundations
  }
}


locals {
  landingzone_tag = {
    "landingzone" = var.landingzone_tag == null ? basename(abspath(path.root)) : var.landingzone_tag
  }

  global_settings = data.terraform_remote_state.landingzone_caf_foundations.outputs.global_settings

  prefix                     = local.global_settings.prefix
  tags                       = merge(var.tags, local.landingzone_tag, { "environment" = local.global_settings.environment })
  caf_foundations_accounting = data.terraform_remote_state.landingzone_caf_foundations.outputs.foundations_accounting
  vnets                   = data.terraform_remote_state.landingzone_networking.outputs.vnets
}


