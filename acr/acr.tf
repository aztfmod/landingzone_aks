# local.vnets[each.value.vnet_key].vnet_subnets
locals {
  # flatten ensures that this local value is a flat list of objects, rather
  # than a list of lists of objects.
  subnet_vnet_keys = transpose(lookup(var.acr,"private_endpoint_vnet_subnet_keys",{}))
}

output "subnet_ids" {
  value = local.subnet_vnet_keys
}

resource "azurecaf_naming_convention" "acr" {
  name          = var.acr.name
  prefix        = var.prefix
  resource_type = "acr"
  max_length    = 25
  convention    = var.convention
}

resource "azurerm_container_registry" "acr" {
  name                      = azurecaf_naming_convention.acr.result
  location                  = var.resource_group.location
  resource_group_name       = var.resource_group.name
  tags                      = var.tags
  sku                       = lookup(var.acr,"sku","Premium")
  admin_enabled             = lookup(var.acr,"admin_enabled",false)
  georeplication_locations  = lookup(var.acr,"georeplication_locations",null)
}

resource "azurerm_private_endpoint" "acr_pe" {
  for_each = local.subnet_vnet_keys
  name                = "${azurerm_container_registry.acr.name}-${each.key}-endpoint"
  location                  = var.resource_group.location
  resource_group_name       = var.resource_group.name
  subnet_id           = var.vnets[each.value[0]].vnet_subnets[each.key]

  private_service_connection {
    name                           = "${azurerm_container_registry.acr.name}-${each.key}-psc"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}
