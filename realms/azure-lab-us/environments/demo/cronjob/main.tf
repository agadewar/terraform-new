terraform {
  backend "azurerm" {
    key = "cronjob.tfstate"
  }
}

provider "kubernetes" {
  version = "1.7.0"
  config_path = "${local.config_path}"
}

provider "null" {
  version = "2.1.0"
}

locals {
  namespace = "${var.environment}"

  config_path = "../../../components/kubernetes/kubeconfig"

  common_tags = "${merge(
    var.realm_common_tags,
    var.environment_common_tags,
    map(
      "Component", "CronJob"
    )
  )}"
}

resource "kubernetes_secret" "banyan_aws" {
  metadata {
    name      = "banyan-aws"
    namespace = "${local.namespace}"
  }

  data = {
    aws_access_key_id     = var.canopy_aws_access_key_id
    aws_secret_access_key = var.canopy_aws_secret_access_key
  }

  type = "Opaque"
}

resource "null_resource" "cronjob_canopy_container_registry_credential_helper" {
  depends_on = [ "kubernetes_secret.banyan_aws" ]

  triggers = {
    config_changed = "${sha1(file("./config/canopy-container-registry-credential-helper.yaml"))}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f ./config/canopy-container-registry-credential-helper.yaml"
  }
}
