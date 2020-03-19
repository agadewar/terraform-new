terraform {
  backend "azurerm" {
    key = "vault.tfstate"
  }

  required_providers {
    helm = "= 1.0.0"
  }
}

provider "azurerm" {
  version = "1.31.0"

  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

provider "helm" {
  # version = "1.0.0"
  kubernetes {
    config_path = local.config_path
  }
}

provider "null" {
  version = "2.1.2"
}

locals {
  resource_group_name = var.resource_group_name
  config_path         = "../../../components/kubernetes/.local/kubeconfig"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Vault"
    },
  )
}

data "terraform_remote_state" "storage_account" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "storage-account.tfstate"
  }
}

resource "azurerm_storage_container" "vault" {
  name                  = "vault-${var.environment}"
  resource_group_name   = var.resource_group_name
  storage_account_name  = data.terraform_remote_state.storage_account.outputs.storage_account_name
  container_access_type = "blob"
  
  lifecycle {
    prevent_destroy = "false"
  }
}

data "template_file" "server_standalone_config" {
  template = file("templates/server-standalone-config.yaml.tpl")

  vars = {
    storage-account = data.terraform_remote_state.storage_account.outputs.storage_account_name
    account-key     = data.terraform_remote_state.storage_account.outputs.storage_account_access_key
    container       = azurerm_storage_container.vault.name
  }
}

resource "local_file" "server_standalone_config" {
  content  = data.template_file.server_standalone_config.rendered
  filename = ".local/server-standalone-config.yaml"
}

### Repo: git clone https://github.com/hashicorp/vault-helm.git files/vault-helm/
### Branch: git checkout v0.4.0
### We have made changes to _helpers.tpl, injector-service.yaml and server-service.yaml.
### Have to install this way because there isn't a helm repo available.
resource "null_resource" "helm_vault" {
  depends_on = [azurerm_storage_container.vault, local_file.server_standalone_config]

  triggers = {
    # manifest_sha1 = "${sha1("${file(".local/server-standalone-config.yaml")}")}"
    server_standalone_config = "${sha1(data.template_file.server_standalone_config.rendered)}"
  }

  provisioner "local-exec" {
    # command = "helm --kubeconfig ${local.config_path} --set fullnameOverride=vault-${var.environment},environment=${var.environment} -n ${var.environment} install -f .local/server-standalone-config.yaml vault files/vault-helm/"
    command = "helm --kubeconfig ${local.config_path} -n ${var.environment} install -f .local/server-standalone-config.yaml vault files/vault-helm/"
  }

  provisioner "local-exec" {
     when = destroy
     
     command = "helm --kubeconfig ${local.config_path} -n ${var.environment} delete vault"
  }
}
