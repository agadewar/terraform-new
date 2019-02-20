terraform {
  backend "azurerm" {
    access_key           = "tsHXP9evG4Azm/RNmmk5yxy18SaZ3RAoi2lKPxQvIPjtMgMsas3fe5tQiMOMMDzZsOeLJ1EtyhLXjHzI+wF2JQ=="
    storage_account_name = "terraformstatelab"
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
