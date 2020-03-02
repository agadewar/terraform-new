data "terraform_remote_state" "app_insights" {
  backend = "azurerm"
  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
	  container_name       = var.realm_backend_container_name
    key                  = "app-insights.tfstate"
  }
}

resource "kubernetes_secret" "app-insights" {
  metadata {
    name = "app-insights"
    namespace = local.namespace
  }

  data = {
      key = data.terraform_remote_state.app_insights.outputs.instrumentation_key
  }
}