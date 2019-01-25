terraform {
  backend "azurerm" {
    access_key           = "gx3N29hLwW2OC+kO5FaAedBpjlh83kY35dpOrJZvdYAB+1CG5iHm85/763rJCiEZ6CY+cwSq+ZAVOvK8f2o4Hg=="
    storage_account_name = "terraformstatesapience"
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
