# -------------------------------------------------------------------------------
# Output Variables
# -------------------------------------------------------------------------------

output "storage_account_access_key" {
  description = "The access key for the storage account"
  value       = azurerm_storage_account.storage_account.primary_access_key
}

output "storage_account_name" {
  description = "The name for the storage account"
  value       = azurerm_storage_account.storage_account.name
}

output "primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = azurerm_storage_account.storage_account.primary_connection_string
}

output "bulk_upload_storage_account_access_key" {
  description = "The access key for the storage account"
  value       = azurerm_storage_account.bulk_upload.primary_access_key
}

output "bulk_upload_storage_account_name" {
  description = "The name for the storage account"
  value       = azurerm_storage_account.bulk_upload.name
}

output "bulk_upload_primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = azurerm_storage_account.bulk_upload.primary_connection_string
}