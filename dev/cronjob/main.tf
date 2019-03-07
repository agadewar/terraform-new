terraform {
  backend "azurerm" {
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
