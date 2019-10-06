# output "aks_egress_ip_address" {
#   value = data.terraform_remote_state.kubernetes_namespace.outputs.aks_egress_ip_address
# }

output "canopy_hierarchy_cosmos_password" {
  description = "Cosmos password for Canopy Hierarchy"
  value       = azurerm_cosmosdb_account.sapience_canopy_hierarchy.primary_master_key
}