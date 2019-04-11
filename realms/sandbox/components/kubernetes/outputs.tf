output "client_key" {
  value = "${azurerm_kubernetes_cluster.kubernetes.kube_config.0.client_key}"
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.kubernetes.kube_config.0.client_certificate}"
}

output "cluster_ca_certificate" {
  value = "${azurerm_kubernetes_cluster.kubernetes.kube_config.0.cluster_ca_certificate}"
}

output "cluster_username" {
  value = "${azurerm_kubernetes_cluster.kubernetes.kube_config.0.username}"
}

output "cluster_password" {
  value = "${azurerm_kubernetes_cluster.kubernetes.kube_config.0.password}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.kubernetes.kube_config_raw}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.kubernetes.kube_config.0.host}"
}

output "kubernetes_location" {
  value = "${azurerm_kubernetes_cluster.kubernetes.location}"
}

output "kubernetes_node_resource_group_name" {
  value = "${data.template_file.node_resource_group.rendered}"
}
