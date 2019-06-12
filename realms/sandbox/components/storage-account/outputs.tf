output "storage_account_access_key" {
  description = "The access key for the storage account"
  value       = "${azurerm_storage_account.storage_account.primary_access_key}"
}

output "storage_account_name" {
  description = "The name for the storage account"
  value       = "${azurerm_storage_account.storage_account.name}"
}