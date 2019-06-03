output "spinnaker_storage_account_access_key" {
  description = "The access key for the storage account"
  value       = "${azurerm_storage_account.spinnaker_storage.primary_access_key}"
}

output "spinnaker_storage_account_name" {
  description = "The name for the storage account"
  value       = "${azurerm_storage_account.spinnaker_storage.name}"
}