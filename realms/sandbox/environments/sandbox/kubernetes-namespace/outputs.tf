output "aks_egress_ip_address" {
  value = "${azurerm_public_ip.aks_egress.ip_address}"
}

output "default_token_secret_name" {
  value = "${data.local_file.default_token_secret_name.content}"
}