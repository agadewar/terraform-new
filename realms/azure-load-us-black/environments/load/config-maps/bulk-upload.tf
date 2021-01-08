resource "kubernetes_config_map" "bulk-upload" {
  metadata {
    name      = "bulk-upload"
    namespace = local.namespace
  }

  data = { 
      "BulkUploadDbConfig__DatabaseName" = "BulkUploadWorkflow"
      "BulkUploadDbConfig__CollectionNames__Events" = "BulkUploadEvents"
      "UploadBlob__Container" = "sapience-upload"
   }
}