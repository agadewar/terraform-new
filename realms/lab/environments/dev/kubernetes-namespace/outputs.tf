output "aks_egress_ip_address" {
  value = "${azurerm_public_ip.aks_egress.ip_address}"
}

output "default_token_secret_name" {
  value = "${data.null_data_source.default_token_secret_name.outputs["data"]}"
}