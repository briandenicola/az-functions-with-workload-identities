resource "azurerm_private_dns_zone" "privatelink_vaultcore_azure_net" {
  name                      = "privatelink.vaultcore.azure.net"
  resource_group_name       = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_vaultcore_azure_net" {
  name                      = "${azurerm_virtual_network.this.name}-link"
  private_dns_zone_name     = azurerm_private_dns_zone.privatelink_vaultcore_azure_net.name
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_id        = azurerm_virtual_network.this.id
}

resource "azurerm_key_vault" "this" {
  name                        = local.keyvault_name
  resource_group_name         = azurerm_resource_group.this.name
  location                    = azurerm_resource_group.this.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  network_acls {
    bypass                    = "AzureServices"
    default_action            = "Deny"
    ip_rules                  = ["${chomp(data.http.myip.body)}"]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.aks_pod_identity.principal_id 

    secret_permissions = [
      "List",
      "Get"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id 

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "List"
    ]
  }
}

resource "azurerm_private_endpoint" "this" {
  name                      = "${local.keyvault_name}-endpoint"
  resource_group_name       = azurerm_resource_group.this.name
  location                  = azurerm_resource_group.this.location
  subnet_id                 = azurerm_subnet.private-endpoints.id

  private_service_connection {
    name                           = "${local.keyvault_name}-endpoint"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = [ "vault" ]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                          = azurerm_private_dns_zone.privatelink_vaultcore_azure_net.name
    private_dns_zone_ids          = [ azurerm_private_dns_zone.privatelink_vaultcore_azure_net.id ]
  }
}