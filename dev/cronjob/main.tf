terraform {
  backend "azurerm" {
    access_key           = "OPAUji+E5XV9vXAouVK5wt7u2ZTfdvVdifj8dUmOcRq9WGjQe5cyciqPZ23ZaffW1P5/GE29OzvLfhmUjl3HQg=="
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
