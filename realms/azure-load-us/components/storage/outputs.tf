output "azure_file_storage_class_name" {
  value = kubernetes_storage_class.azure_file.metadata[0].name
}