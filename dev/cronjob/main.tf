terraform {
  backend "azurerm" {
    access_key           = "lo8HUaHNNDrFRHsTL+5uNuykv+WfQSHNxgXWqdcxE2vbk/eiSgaZx+gP2bHdU9TWKJk+PqhhyB0wY95wOCLDoQ=="
    storage_account_name = "tfstatelower"
	  container_name       = "tfstate"
    key                  = "sapience.dev.cronjob.terraform.tfstate"
  }
}

provider "null" {
  version = "2.0.0"
}

resource "null_resource" "cronjob_canopy_container_registry_credential_helper" {

  triggers {
    config_changed = "${sha1(file("./config/canopy-container-registry-credential-helper.yaml"))}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=../../lab/kubernetes/kubeconfig -f ./config/canopy-container-registry-credential-helper.yaml"
  }
}
