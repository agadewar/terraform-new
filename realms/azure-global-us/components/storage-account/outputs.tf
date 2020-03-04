output "storage_account_gen_v2_access_key" {
  value       = azurerm_storage_account.storage_account_gen_v2.primary_access_key
}

output "storage_account_gen_v2_name" {
  value       = azurerm_storage_account.storage_account_gen_v2.name
}

output "storage_account_gen_v2_primary_connection_string" {
  value       = azurerm_storage_account.storage_account_gen_v2.primary_connection_string
}

output "storage_account_file_access_key" {
  value       = azurerm_storage_account.storage_account_file.primary_access_key
}

output "storage_account_file_name" {
  value       = azurerm_storage_account.storage_account_file.name
}

output "storage_account_file_primary_connection_string" {
  value       = azurerm_storage_account.storage_account_file.primary_connection_string
}