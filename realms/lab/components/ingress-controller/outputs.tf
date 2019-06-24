output "nginx_ingress_controller_ip" {
  value = "${data.local_file.nginx_ingress_controller_ip.content}"
}
