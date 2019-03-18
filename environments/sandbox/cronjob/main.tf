terraform {
  backend "azurerm" {
    key = "sapience.environment.sandbox.cronjob.terraform.tfstate"
  }
}

provider "null" {
  version = "2.0.0"
}

locals {
  namespace = "${var.environment}"

  config_path = "../../../realms/${var.realm}/kubernetes/kubeconfig"

  common_tags = "${merge(
    var.realm_common_tags,
    var.environment_common_tags,
    map(
      "Component", "CronJob"
    )
  )}"
}

resource "null_resource" "cronjob_canopy_container_registry_credential_helper" {

  triggers {
    config_changed = "${sha1(file("./config/canopy-container-registry-credential-helper.yaml"))}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f ./config/canopy-container-registry-credential-helper.yaml"
  }
}
