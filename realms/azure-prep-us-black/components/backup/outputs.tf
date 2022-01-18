output "vault" {
  value = "${azurerm_recovery_services_vault.vault.name}"
}

output "id_daily_14" {
    value = "${azurerm_recovery_services_protection_policy_vm.daily_14.id}"
}