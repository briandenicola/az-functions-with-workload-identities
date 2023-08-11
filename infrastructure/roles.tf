resource "azurerm_role_assignment" "aks" {
  scope                = azurerm_virtual_network.this.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

resource "azurerm_role_assignment" "aks_role_assignment_msi" {
  scope                     = azurerm_user_assigned_identity.aks_kubelet_identity.id
  role_definition_name      = "Managed Identity Operator"
  principal_id              = azurerm_user_assigned_identity.aks_identity.principal_id
  skip_service_principal_aad_check = true 
}

resource "azurerm_role_assignment" "azurerm_application_insights" {
  scope                     = azurerm_application_insights.this.id
  role_definition_name      = "Monitoring Metrics Publisher"
  principal_id              = azurerm_user_assigned_identity.aks_pod_identity.principal_id
  skip_service_principal_aad_check = true 
}

resource "azurerm_role_assignment" "blob" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_pod_identity.principal_id
  skip_service_principal_aad_check = true  
}

resource "azurerm_role_assignment" "storage" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_pod_identity.principal_id
  skip_service_principal_aad_check = true  
}

resource "azurerm_role_assignment" "queue" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_pod_identity.principal_id
  skip_service_principal_aad_check = true  
}

resource "azurerm_role_assignment" "hub" {
  scope                = azurerm_eventhub_namespace.this.id
  role_definition_name = "Azure Event Hubs Data Owner"
  principal_id         = azurerm_user_assigned_identity.aks_pod_identity.principal_id
  skip_service_principal_aad_check = true  
}

resource "azurerm_role_assignment" "client" {
  scope                = azurerm_eventhub_namespace.this.id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = data.azurerm_client_config.current.object_id
}