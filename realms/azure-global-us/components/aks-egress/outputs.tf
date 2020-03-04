output "aks_egress_ip_address" {
  value = "${azurerm_public_ip.aks_egress.ip_address}"
}