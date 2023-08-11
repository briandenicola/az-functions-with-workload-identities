output "APP_NAME" {
  value     = local.resource_name
  sensitive = false
}

output "AKS_RESOURCE_GROUP" {
  value     = azurerm_kubernetes_cluster.this.resource_group_name
  sensitive = false
}

output "AKS_CLUSTER_NAME" {
  value     = azurerm_kubernetes_cluster.this.name
  sensitive = false
}

output "APP_IDENTITY_NAME" {
  value     = azurerm_user_assigned_identity.aks_pod_identity.name
  sensitive = false
}

output "ARM_WORKLOAD_APP_ID" {
  value     = azurerm_user_assigned_identity.aks_pod_identity.client_id
  sensitive = false
}

output "ARM_TENANT_ID" {
  value     = azurerm_user_assigned_identity.aks_pod_identity.tenant_id
  sensitive = false
}

output "EVENTHUB_NAMESPACE_NAME" {
  value     = azurerm_eventhub_namespace.this.name
  sensitive = false
}

output "WEBJOB_STORAGE_ACCOUNT_NAME" {
  value     = azurerm_storage_account.this.name
  sensitive = false
}

output "SQL_CONNECTION" {
  value = "Server=${azurerm_mssql_server.this.fully_qualified_domain_name};Database=${local.database_name};Encrypt=true;Authentication=Active Directory Managed Identity"
  sensitive = false
}