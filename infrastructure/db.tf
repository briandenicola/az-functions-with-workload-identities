resource "random_password" "postgresql_user_password" {
  length           = 25
  special          = false
}

resource "azurerm_private_dns_zone" "privatelink_postgres_database_azure_com" {
  name                      = "privatelink.postgres.database.azure.com"
  resource_group_name       = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_postgres_database_azure_com" {
  name                    = "${azurerm_virtual_network.this.name}-link"
  private_dns_zone_name   = azurerm_private_dns_zone.privatelink_postgres_database_azure_com.name
  resource_group_name     = azurerm_resource_group.this.name
  virtual_network_id      = azurerm_virtual_network.this.id
}

resource "azurerm_postgresql_flexible_server" "this" {
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.privatelink_postgres_database_azure_com
  ]
  name                   = local.postgresql_name
  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  delegated_subnet_id    = azurerm_subnet.sql.id
  private_dns_zone_id    = azurerm_private_dns_zone.privatelink_postgres_database_azure_com.id
  version                = "12"
  administrator_login    = "manager"
  administrator_password = random_password.postgresql_user_password.result
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2ds_v4"
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name                = local.postgresql_database_name
  server_id           = azurerm_postgresql_flexible_server.this.id
  collation           = "en_US.utf8"
  charset             = "utf8"
}

resource "azurerm_key_vault_secret" "postgresql_connection_string" {
  name         = "postgresqlconnection"
  value        = "host=${local.postgresql_name}.postgres.database.azure.com user=manager password=${random_password.postgresql_user_password.result} port=5432 dbname=${local.postgresql_database_name} sslmode=require"
  key_vault_id = azurerm_key_vault.this.id
}
