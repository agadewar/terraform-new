resource "kubernetes_secret" "bulk-upload" {
  metadata {
    name = "bulk-upload"
    namespace = local.namespace
  }

  data = {
      UploadBlob__StorageAccountAccessKey = var.UploadBlob__StorageAccountAccessKey
      BulkUploadDbConfig__ConnString = var.BulkUploadDbConfig__ConnString
      AzureServiceBus__EndpointEndpoint = var.AzureServiceBus__EndpointEndpoint
      ConnectionStrings__Admin = var.connectionstring_admin
  }
}