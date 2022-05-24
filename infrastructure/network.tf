resource "azurerm_virtual_network" "this" {
  name                = "${local.resource_name}-network"
  address_space       = ["10.25.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "aks" {
  name                 = "kubernetes"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.25.2.0/24"]
}

resource "azurerm_subnet" "sql" {
  name                  = "sql"
  resource_group_name   = azurerm_virtual_network.this.resource_group_name
  virtual_network_name  = azurerm_virtual_network.this.name
  address_prefixes      = ["10.25.3.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "private-endpoints" {
  name                 = "private-endpoints"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.25.4.0/24"]
}

resource "azurerm_network_security_group" "this" {
  name                = "${local.resource_name}-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_subnet_network_security_group_association" "servers" {
  subnet_id                 = azurerm_subnet.sql.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_subnet_network_security_group_association" "private-endpoints" {
  subnet_id                 = azurerm_subnet.private-endpoints.id
  network_security_group_id = azurerm_network_security_group.this.id
}

