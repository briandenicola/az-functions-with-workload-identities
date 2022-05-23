resource "azurerm_eventhub_namespace" "this" {
  name                     = "${local.eventhub_name}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  sku                      = "Standard"
  maximum_throughput_units = 5
  auto_inflate_enabled     = true
}

resource "azurerm_eventhub" "this" {
  name                  = "requests"
  namespace_name        = azurerm_eventhub_namespace.this.name
  resource_group_name   = azurerm_resource_group.this.name
  partition_count       = 15
  message_retention     = 7
}

resource "azurerm_eventhub_consumer_group" "this" {
  name                  = "functions-client"
  namespace_name        = azurerm_eventhub_namespace.this.name
  eventhub_name         = azurerm_eventhub.this.name
  resource_group_name   = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone" "privatelink_servicebus_windows_net" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_servicebus_windows_net" {
  name                  = "${azurerm_virtual_network.this.name}-link"
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_servicebus_windows_net.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_endpoint" "eventhub_namespace" {
  name                = "${local.eventhub_name}-endpoint"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = azurerm_subnet.private-endpoints.id

  private_service_connection {
    name                           = "${local.eventhub_name}-link"
    private_connection_resource_id = azurerm_eventhub_namespace.this.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.privatelink_servicebus_windows_net.name
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_servicebus_windows_net.id]
  }
}
