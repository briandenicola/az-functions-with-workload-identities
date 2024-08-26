resource "azurerm_storage_account" "this" {
  name                      = local.storage_account_name
  resource_group_name       = azurerm_resource_group.this.name
  location                  = azurerm_resource_group.this.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  shared_access_key_enabled = false
}

resource "azurerm_private_dns_zone" "privatelink_blob_core_windows_net" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_blob_core_windows_net" {
  name                  = "${azurerm_virtual_network.this.name}-link"
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_blob_core_windows_net.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
}
resource "azurerm_private_endpoint" "storage_account" {
  name                = "${local.storage_account_name}-blob-endpoint"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = azurerm_subnet.private-endpoints.id

  private_service_connection {
    name                           = "${local.storage_account_name}-blob-link"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.privatelink_blob_core_windows_net.name
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_blob_core_windows_net.id]
  }
}

resource "azurerm_private_dns_zone" "privatelink_queue_core_windows_net" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_queue_core_windows_net" {
  name                  = "${azurerm_virtual_network.this.name}-link"
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_queue_core_windows_net.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_endpoint" "storage_account_queue" {
  name                = "${local.storage_account_name}-queue-endpoint"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = azurerm_subnet.private-endpoints.id

  private_service_connection {
    name                           = "${local.storage_account_name}-queue-link"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["queue"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.privatelink_queue_core_windows_net.name
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_queue_core_windows_net.id]
  }
}
