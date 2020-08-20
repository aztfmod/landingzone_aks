
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
  name                = "acr-endpoint"
  location                  = var.resource_group.location
  resource_group_name       = var.resource_group.name
  subnet_id           = azurerm_subnet.endpoint.id

  private_service_connection {
    name                           = "acr-privateserviceconnection"
    private_connection_resource_id = azurerm_private_link_service.example.id
    is_manual_connection           = false
  }
}