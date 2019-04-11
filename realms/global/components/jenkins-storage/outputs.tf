output "jenkins_home_disk_id" {
  value       = "${azurerm_managed_disk.jenkins_home.id}"
}

/* output "maven_repo_disk_id" {
  value       = "${azurerm_managed_disk.maven_repo.id}"
} */