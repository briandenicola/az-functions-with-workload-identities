data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "http://checkip.amazonaws.com/"
}

resource "random_id" "this" {
  byte_length = 2
}

resource "random_pet" "this" {
  length    = 1
  separator = ""
}

resource "random_password" "password" {
  length = 25
  special = true
}

resource "random_integer" "vnet_cidr" {
  min = 10
  max = 250
}

resource "random_integer" "services_cidr" {
  min = 64
  max = 99
}

resource "random_integer" "pod_cidr" {
  min = 100
  max = 127
}

locals {
  location                 = var.region
  resource_name            = "${random_pet.this.id}-${random_id.this.dec}"
  storage_account_name     = "${random_pet.this.id}${random_id.this.dec}sa"
  aks_name                 = "${local.resource_name}-aks"
  eventhub_name            = "${local.resource_name}-eventhub"
  keyvault_name            = "${local.resource_name}-keyvault"
  workload_identity        = "${local.aks_name}-${var.namespace}-identity"
  sql_name                 = "${local.resource_name}-sql"
  database_name            = "results"
  vnet_cidr                = cidrsubnet("10.0.0.0/8", 8, random_integer.vnet_cidr.result)
  pe_subnet_cidir          = cidrsubnet(local.vnet_cidr, 8, 1)
  api_subnet_cidir         = cidrsubnet(local.vnet_cidr, 8, 2)
  nodes_subnet_cidir       = cidrsubnet(local.vnet_cidr, 8, 3)
  sql_subnet_cidir         = cidrsubnet(local.vnet_cidr, 8, 10)
}

resource "azurerm_resource_group" "this" {
  name     = "${local.resource_name}_rg"
  location = local.location

  tags = {
    Application = "event-processor"
    Components  = "aks; functions; postgresql; pod-identities"
    DeployedOn  = timestamp()
  }
}
