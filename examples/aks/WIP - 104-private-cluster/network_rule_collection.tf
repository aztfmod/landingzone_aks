resource "azurerm_firewall_network_rule_collection" "aksnrc" {
  name                = "aks"
  azure_firewall_name = var.az_firewall_settings.az_fw_name
  resource_group_name = var.az_firewall_settings.az_object.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name = "ntp"
    source_addresses = [
      "100.64.48.0/22"
    ]
    destination_ports = [
      "123"
    ]
    destination_addresses = [
      "*"
    ]
    protocols = [
      "UDP"
    ]
  }

  rule {
    name = "monitor"
    source_addresses = [
      "100.64.48.0/22"
    ]
    destination_ports = [
      "443"
    ]
    destination_addresses = [
      "*"
    ]
    protocols = [
      "TCP"
    ]
  }
}

resource "azurerm_firewall_application_rule_collection" "aksarc" {
  name                = "aks"
  azure_firewall_name = var.az_firewall_settings.az_fw_name
  resource_group_name = var.az_firewall_settings.az_object.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name = "aks"
    source_addresses = [
      "100.64.48.0/22",
    ]
    fqdn_tags = [
      "AzureKubernetesService",
    ]
  }

  rule {
    name = "ubuntu"
    source_addresses = [
      "100.64.48.0/22",
    ]
    target_fqdns = [
      "security.ubuntu.com", "azure.archive.ubuntu.com", "changelogs.ubuntu.com"
    ]
    protocol {
      port = "80"
      type = "Http"
    }
  }
}

resource "azurerm_route_table" "aks_route" {
  name                          = "aksroute"
  location                      = "eastus"
  resource_group_name           = var.az_firewall_settings.az_object.resource_group_name
  disable_bgp_route_propagation = false

  route {
    name           = "azfw"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    //theoritcally should be: next_hop_in_ip_address      = var.route_nexthop_type == "VirtualAppliance" ? "${var.route_nexthop_ip}" : null
    next_hop_in_ip_address = "100.64.101.4"
  }
}

resource "azurerm_subnet_route_table_association" "aks_route_subnet1_association" {
  subnet_id      = "/subscriptions/30e02b61-1190-4a13-9a5e-1303a1e5f87b/resourceGroups/lcay-rg-vnet-eus-byDTMKMxPvAqjgUdQv6YV9f/providers/Microsoft.Network/virtualNetworks/lcay-vnet-aks-eXD7FNsyqK39wD2fNKNQit2TyzV1FB4jtxY2R6xwNtPG7t/subnets/aks_nodepool_system"
  route_table_id = azurerm_route_table.aks_route.id
}

resource "azurerm_subnet_route_table_association" "aks_route_subnet2_association" {
  subnet_id      = "/subscriptions/30e02b61-1190-4a13-9a5e-1303a1e5f87b/resourceGroups/lcay-rg-vnet-eus-byDTMKMxPvAqjgUdQv6YV9f/providers/Microsoft.Network/virtualNetworks/lcay-vnet-aks-eXD7FNsyqK39wD2fNKNQit2TyzV1FB4jtxY2R6xwNtPG7t/subnets/aks_nodepool_user1"
  route_table_id = azurerm_route_table.aks_route.id
}
