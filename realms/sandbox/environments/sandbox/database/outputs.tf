output "aks_egress_ip_address" {
  value = "${data.terraform_remote_state.kubernetes_namespace.aks_egress_ip_address}"
}
