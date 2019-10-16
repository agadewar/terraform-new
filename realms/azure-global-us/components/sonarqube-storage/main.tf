terraform {
  backend "azurerm" {
    key = "sonarqube-storage.tfstate"
  }
}

provider "azurerm" {
  version = "1.31.0"
  
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.service_principal_app_id}"
  client_secret   = "${var.service_principal_password}"
  tenant_id       = "${var.service_principal_tenant}"
}

provider "kubernetes" {
  config_path = local.config_path
}

locals {
  config_path = "../kubernetes/.local/kubeconfig"
  namespace   = "sonarqube"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "SonarQube Storage"
    )
  )}"
}

data "template_file" "sonarqube_home_pv" {
  template = "${file("templates/sonarqube-home-pv.yaml.tpl")}"

  vars = {
    subscription_id = "${var.subscription_id}"
    resource_group_name = "${var.resource_group_name}"
  }
}

data "template_file" "sonarqube_postgresql_pv" {
  template = "${file("templates/sonarqube-postgresql-pv.yaml.tpl")}"

  vars = {
    subscription_id = "${var.subscription_id}"
    resource_group_name = "${var.resource_group_name}"
  }
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.namespace
  }
}

resource "azurerm_managed_disk" "sonarqube_home" {
  name                 = "sonarqube-home"
  location             = "${var.resource_group_location}"
  resource_group_name  = "${var.resource_group_name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "25"

  tags = "${merge(
    local.common_tags
  )}"
  
  lifecycle{
    prevent_destroy = "false"
  }
}

resource "azurerm_managed_disk" "sonarqube_postgresql" {
  name                 = "sonarqube-postgresql"
  location             = "${var.resource_group_location}"
  resource_group_name  = "${var.resource_group_name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "25"

  tags = "${merge(
    local.common_tags
  )}"
  
  lifecycle{
    prevent_destroy = "false"
  }
}

resource "kubernetes_persistent_volume_claim" "sonarqube_home" {
  depends_on = [ "null_resource.sonarqube_home_pv","kubernetes_namespace.namespace" ]
  
  metadata {
    annotations = "${merge(
      local.common_tags
    )}"
    
    name = "sonarqube-home"
    namespace = "${local.namespace}"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "25G"
      }
    }
    volume_name = "sonarqube-home"  // This is what it should be when PV is created under TF: "${null_resource.sonarqube.metadata.0.name}"
    storage_class_name = "${kubernetes_storage_class.sonarqube_home.metadata.0.name}"
  }
}

resource "null_resource" "sonarqube_home_pv" {
  triggers = {
    template_changed = "${data.template_file.sonarqube_home_pv.rendered}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -f - <<EOF\n${data.template_file.sonarqube_home_pv.rendered}\nEOF"
  }

  provisioner "local-exec" {
    when = "destroy"

    command = "kubectl delete --kubeconfig=${local.config_path} persistentvolume sonarqube-home"
  }  
}

resource "kubernetes_storage_class" "sonarqube_home" {
  metadata {
    annotations = "${merge(
      local.common_tags
    )}"
    
    name = "sonarqube-home"
  }

  storage_provisioner = "kubernetes.io/azure-disk"
  reclaim_policy = "Retain"
  parameters = {
    storageaccounttype = "Standard_LRS"
  }
}

resource "kubernetes_persistent_volume_claim" "sonarqube_postgresql" {
  depends_on = [ "null_resource.sonarqube_postgresql_pv","kubernetes_namespace.namespace" ]
  
  metadata {
    annotations = "${merge(
      local.common_tags
    )}"
    
    name = "sonarqube-postgresql"
    namespace = "${local.namespace}"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "25G"
      }
    }
    volume_name = "sonarqube-postgresql"  // This is what it should be when PV is created under TF: "${null_resource.sonarqube_postgresql.metadata.0.name}"
    storage_class_name = "${kubernetes_storage_class.sonarqube_postgresql.metadata.0.name}"
  }
}

resource "null_resource" "sonarqube_postgresql_pv" {
  triggers = {
    template_changed = "${data.template_file.sonarqube_postgresql_pv.rendered}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -f - <<EOF\n${data.template_file.sonarqube_postgresql_pv.rendered}\nEOF"
  }

  provisioner "local-exec" {
    when = "destroy"

    command = "kubectl delete --kubeconfig=${local.config_path} persistentvolume sonarqube-postgresql"
  }  
}

resource "kubernetes_storage_class" "sonarqube_postgresql" {
  metadata {
    annotations = "${merge(
      local.common_tags
    )}"
    
    name = "sonarqube-postgresql"
  }

  storage_provisioner = "kubernetes.io/azure-disk"
  reclaim_policy = "Retain"
  parameters = {
    storageaccounttype = "Standard_LRS"
  }
}
