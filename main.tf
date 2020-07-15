terraform {
  backend "azurerm" {
  }
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
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

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {}

data "terraform_remote_state" "landingzone_networking" {
  backend = "azurerm"
  config = {
    storage_account_name  = var.lowerlevel_storage_account_name
    container_name        = var.workspace 
    resource_group_name   = var.lowerlevel_resource_group_name
    key                   = "landingzone_networking.tfstate"
  }
}

data "terraform_remote_state" "landingzone_caf_foundations" {
  backend = "azurerm"
  config = {
    storage_account_name  = var.lowerlevel_storage_account_name
    container_name        = var.workspace 
    resource_group_name   = var.lowerlevel_resource_group_name
    key                   = "landingzone_caf_foundations.tfstate"
  }
}


locals {    
  landingzone_tag          = {
    "landingzone" = basename(abspath(path.root))
    "workspace"   = var.workspace
  }
  
  prefix                    = data.terraform_remote_state.landingzone_caf_foundations.outputs.prefix
  tags                      = merge(var.tags, local.landingzone_tag)
  caf_foundations_accounting = data.terraform_remote_state.landingzone_caf_foundations.outputs.foundations_accounting

  diagnostics_map                   = local.caf_foundations_accounting.diagnostics_map
  log_analytics_workspace           = local.caf_foundations_accounting.log_analytics_workspace
  
  vnet_name                 = data.terraform_remote_state.landingzone_networking.outputs.vnet.vnet_name
  subnet_id_by_name         = data.terraform_remote_state.landingzone_networking.outputs.subnet_id_by_name
  subnet_keys               = data.terraform_remote_state.landingzone_networking.outputs.subnet_id_by_key
}


