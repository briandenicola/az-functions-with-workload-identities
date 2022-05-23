resource "azurerm_role_assignment" "aks" {
  scope                = azurerm_virtual_network.this.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "azurerm_application_insights" {
  scope                = azurerm_application_insights.this.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azuread_service_principal.this.object_id
  skip_service_principal_aad_check = true 
}

resource "azurerm_role_assignment" "blob" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.this.object_id
  skip_service_principal_aad_check = true  
}

resource "azurerm_role_assignment" "hub" {
  scope                = azurerm_eventhub.this.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azuread_service_principal.this.object_id
  skip_service_principal_aad_check = true  
}