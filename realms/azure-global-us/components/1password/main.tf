# See: https://www.blazemeter.com/blog/how-to-setup-scalable-jenkins-on-top-of-a-kubernetes-cluster

terraform {
  backend "azurerm" {
    key = "1password.tfstate"
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
  config_path = "${local.config_path}"
}

data "terraform_remote_state" "container_registry" {
  backend = "azurerm"
  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "container-registry.tfstate"
  }
}

data "terraform_remote_state" "dns" {
  backend = "azurerm"
  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "dns.tfstate"
  }
}

data "terraform_remote_state" "1password_storage" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "1password-storage.tfstate"
  }
}

data "terraform_remote_state" "ingress-controller" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "ingress-controller.tfstate"
  }
}

data "terraform_remote_state" "kubernetes" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "kubernetes.tfstate"
  }
}

locals {
  config_path = "../kubernetes/.local/kubeconfig"
  namespace = "1password"
  sapience_container_registry_image_pull_secret_name = "sapience-container-registry-credential"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "1Password"
    )
  )}"
}

data "template_file" "sapience_container_registry_credential" {
  template = "${file("templates/dockerconfigjson.tpl")}"

  vars = {
     server   = data.terraform_remote_state.container_registry.outputs.login_server
     username = data.terraform_remote_state.container_registry.outputs.admin_username
     password = data.terraform_remote_state.container_registry.outputs.admin_password
  }
}

resource "kubernetes_secret" "sapience_container_registry_credential" {
  metadata {
    name      = "${local.sapience_container_registry_image_pull_secret_name}"
    namespace = "${local.namespace}"
  }

  data = {
    ".dockerconfigjson" = "${data.template_file.sapience_container_registry_credential.rendered}"
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "${local.namespace}"
  }
}

resource "kubernetes_deployment" "jenkins" {
  depends_on = [ "kubernetes_service_account.jenkins", "kubernetes_persistent_volume_claim.jenkins_home" ]

  metadata {
    annotations = "${merge(
      local.common_tags
    )}"

    name = "jenkins"
    namespace = "${local.namespace}"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "jenkins"
      }
    }
    template {
      metadata {
        labels = {
          app = "jenkins"
        }
      }
      spec {
        service_account_name = "jenkins"

        security_context {
            fs_group = 1000
            run_as_user = 1000
        }
        container {
          name = "jenkins"
          # image = "jenkins/jenkins:2.169"
          image = "${data.terraform_remote_state.container_registry.outputs.login_server}/jenkins:1.12"
          image_pull_policy = "Always"

          resources {
            requests {
              cpu    = "250m"
              memory = "2000Mi"
            }
          }

          env {
            name = "JAVA_OPTS"
            value = "-Djenkins.install.runSetupWizard=false"
          }
          port {
            name = "http-port"
            container_port = 8080
          }
          port {
            name = "jnlp-port"
            container_port = 50000
          }
          volume_mount {
            name = "jenkins-home"
            mount_path = "/var/jenkins_home"
          }
        }
        
        volume {
          name = "jenkins-home"
          persistent_volume_claim { 
            claim_name = "${kubernetes_persistent_volume_claim.jenkins_home.metadata.0.name}"
          }
        }

        image_pull_secrets {
          name = "${kubernetes_secret.sapience_container_registry_credential.metadata.0.name}"
        }
      }
    }
  }
}

resource "kubernetes_service" "jenkins" {
  metadata {
    annotations = "${merge(
      local.common_tags
    )}"
    
    name = "jenkins"
    namespace = "${local.namespace}"
  }

  spec {
    type = "ClusterIP"
    selector = {
      app = "jenkins"
    }
    port {
      name = "http"
      port = 80
      target_port = 8080
    }

    port {
      name = "jnlp"
      port = 50000
      target_port = 50000
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jenkins_home" {
  depends_on = [ "null_resource.jenkins_home_pv" ]
  
  metadata {
    annotations = "${merge(
      local.common_tags
    )}"
    
    name = "jenkins-home"
    namespace = "${local.namespace}"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10G"
      }
    }
    volume_name = "jenkins-home"  // This is what it should be when PV is created under TF: "${null_resource.jenkins_home.metadata.0.name}"
    storage_class_name = "${kubernetes_storage_class.jenkins_home.metadata.0.name}"
  }
}

data "template_file" "jenkins_home_pv" {
  template = "${file("templates/jenkins-home-pv.yaml.tpl")}"

  vars = {
    # realm = "${var.realm}"
    subscription_id = "${var.subscription_id}"
    resource_group_name = "${var.resource_group_name}"
    # secret_name = "${kubernetes_secret.maven_repo_azure_file.metadata.0.name}"
  }
}

resource "null_resource" "password_home_pv" {
  triggers = {
    template_changed = md5("${data.template_file.password_home_pv.rendered}")
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -f - <<EOF\n${data.template_file.jenkins_home_pv.rendered}\nEOF"
  }

  provisioner "local-exec" {
    when = "destroy"

    command = "kubectl delete --kubeconfig=${local.config_path} persistentvolume jenkins-home"
  }  
}

resource "kubernetes_storage_class" "jenkins_home" {
  metadata {
    annotations = "${merge(
      local.common_tags
    )}"
    
    name = "jenkins"
  }

  storage_provisioner = "kubernetes.io/azure-disk"
  reclaim_policy = "Retain"
  parameters = {
    storageaccounttype = "Standard_LRS"
  }
}

resource "kubernetes_secret" "maven_repo_azure_file" {
  metadata {
    annotations = "${merge(
      local.common_tags
    )}"
    
    name = "maven-repo-azure-file"
    namespace = "${local.namespace}"
  }

  data = {
    # azurestorageaccountname = "${data.terraform_remote_state.jenkins_storage.outputs.maven_repo_storage_account_name}"
    # azurestorageaccountkey  = "${data.terraform_remote_state.jenkins_storage.outputs.maven_repo_storage_account_access_key}"
    azurestorageaccountname = data.terraform_remote_state.storage_account.outputs.storage_account_file_name
    azurestorageaccountkey  = data.terraform_remote_state.storage_account.outputs.storage_account_file_access_key
  }
}

resource "kubernetes_persistent_volume_claim" "maven_repo" {
  depends_on = [ "null_resource.maven_repo_storage_class", "null_resource.maven_repo_pv" ]
  
  metadata {
    annotations = "${merge(
      local.common_tags
    )}"
    
    name = "maven-repo"
    namespace = "${local.namespace}"
  }

  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "20G"
      }
    }
    volume_name = "maven-repo"  // This is what it should be when PV is created under TF: "${null_resource.maven_repo.metadata.0.name}"
    storage_class_name = "maven-repo"
  }
}

data "template_file" "maven_repo_pv" {
  template = "${file("templates/maven-repo-pv.yaml.tpl")}"

  vars = {
    # realm = "${var.realm}"
    subscription_id = "${var.subscription_id}"
    resource_group_name = "${var.resource_group_name}"
    secret_name = "${kubernetes_secret.maven_repo_azure_file.metadata.0.name}"
    # share_name = "${data.terraform_remote_state.jenkins_storage.outputs.maven_repo_storage_account_name}"
    share_name = data.terraform_remote_state.storage_account.outputs.storage_account_file_name
  }
}

resource "null_resource" "maven_repo_pv" {
  depends_on = [ "null_resource.maven_repo_storage_class" ]

  triggers = {
    template_changed = "${data.template_file.maven_repo_pv.rendered}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -f - <<EOF\n${data.template_file.maven_repo_pv.rendered}\nEOF"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "kubectl delete --kubeconfig=${local.config_path} persistentvolume maven-repo"
  }
}

data "template_file" "maven_repo_storage_class" {
  template = "${file("templates/maven-repo-storage-class.yaml.tpl")}"
}

resource "null_resource" "maven_repo_storage_class" {
  triggers = {
    template_changed = "${data.template_file.maven_repo_storage_class.rendered}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -f - <<EOF\n${data.template_file.maven_repo_storage_class.rendered}\nEOF"
  }
}

resource "kubernetes_service_account" "1password" {
  metadata {
    annotations = "${merge(
      local.common_tags
    )}"
    
    name = "1password"
    namespace = "${kubernetes_namespace.1password.metadata.0.name}"
  }
}

resource "kubernetes_cluster_role_binding" "1password" {
  metadata {
    annotations = "${merge(
      local.common_tags
    )}"
    
    name = "1password"
  }

    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "cluster-admin"
    }
    subject {
        kind = "ServiceAccount"
        name = "1password"
        namespace = local.namespace
        api_group = ""
    }
}

resource "azurerm_dns_a_record" "1password" {
  name                = "1password.${var.dns_realm}.${var.region}.${var.cloud}"
  zone_name           = "${data.terraform_remote_state.dns.outputs.sapienceanalytics_public_zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = 30
  records             = [ "${data.terraform_remote_state.ingress-controller.outputs.nginx_ingress_controller_ip}" ]
}

resource "kubernetes_ingress" "1password" {
  metadata {
    name = "1password"
    namespace = "${local.namespace}"

    annotations = {
      "certmanager.k8s.io/acme-challenge-type"             = "dns01"
      "certmanager.k8s.io/acme-dns01-provider"             = "azure-dns"
      "certmanager.k8s.io/cluster-issuer"                  = "letsencrypt-prod"
      "kubernetes.io/ingress.class"                        = "nginx"
      "kubernetes.io/tls-acme"                             = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect"           = "true"
      "nginx.ingress.kubernetes.io/whitelist-source-range" = "${join(", ", var.1password_source_ranges_allowed)}"
    }
  }

  spec {
    rule {
      host = "1password.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com"
      http {
        path {
          backend {
            service_name = "1password"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    rule {
      host = "1password.sapienceanalytics.com"
      http {
        path {
          backend {
            service_name = "1password"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    tls {
      hosts = [ 
        "1password.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com",
        "1password.sapienceanalytics.com"
      ]
      secret_name = "1password-certs"
    }
  }
}

# ### TODO - remove this... once the Kubernetes cluster supports both Linux and Windows agent pools, this can go away.  Because the ingress only supports 80 and 443, JNLP from the windows
# ###        is not able to get to the master.
# resource "kubernetes_service" "jenkins_jnlp" {
#   metadata {
#     annotations = "${merge(
#       local.common_tags,
#       map()
#     )}"
    
#     name = "jenkins"
#     namespace = "${local.namespace}"
#   }

#   spec {
#     type = "LoadBalancer"
#     selector {
#       app = "jenkins"
#     }
#     port {
#       name = "http"
#       port = 80
#       target_port = 8080
#     }

#     port {
#       name = "jnlp"
#       port = 50000
#       target_port = 50000
#     }

#     load_balancer_source_ranges = "${var.load_balancer_source_ranges_allowed}"
#   }
# }