# See: https://www.blazemeter.com/blog/how-to-setup-scalable-jenkins-on-top-of-a-kubernetes-cluster

terraform {
  backend "azurerm" {
    key = "sapience.realm.sandbox.jenkins.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

provider "kubernetes" {
  config_path = "${local.config_path}"
}

data "terraform_remote_state" "jenkins_storage" {
  backend = "azurerm"

  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "${var.backend_container_name}"
    key                  = "sapience.realm.${var.realm}.jenkins-storage.terraform.tfstate"
  }
}

data "terraform_remote_state" "kubernetes" {
  backend = "azurerm"

  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "${var.backend_container_name}"
    key                  = "sapience.realm.${var.realm}.kubernetes.terraform.tfstate"
  }
}

/* data "terraform_remote_state" "dns" {
  backend = "azurerm"
  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "${var.backend_container_name}"
    key                  = "sapience.environment.${var.environment}.dns.terraform.tfstate"
  }
} */

locals {
  config_path = "../kubernetes/kubeconfig"
  namespace = "cicd"
  sapience_container_registry_image_pull_secret_name = "sapience-container-registry-credential"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "Jenkins"
    )
  )}"
}

data "template_file" "sapience_container_registry_credential" {
  template = "${file("templates/dockerconfigjson.tpl")}"

  vars {
     server   = "${var.sapience_container_registry_hostname}"
     username = "${var.sapience_container_registry_username}"
     password = "${var.sapience_container_registry_password}"
  }
}

resource "kubernetes_secret" "sapience_container_registry_credential" {
  metadata {
    name      = "${local.sapience_container_registry_image_pull_secret_name}"
    namespace = "${local.namespace}"
  }

  data {
    ".dockerconfigjson" = "${data.template_file.sapience_container_registry_credential.rendered}"
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "${local.namespace}"
  }
}

resource "kubernetes_deployment" "jenkins" {
  metadata {
    annotations = "${merge(
      local.common_tags,
      map()
    )}"

    name = "jenkins"
    namespace = "${local.namespace}"
  }
  spec {
    replicas = 1
    selector {
      match_labels {
        app = "jenkins"
      }
    }
    template {
      metadata {
        labels {
          app = "jenkins"
        }
      }
      spec {
        security_context {
            fs_group = 1000
            run_as_user = 1000
        }
        container {
          name = "jenkins"
          # image = "jenkins/jenkins:2.169"
          image = "${var.sapience_container_registry_hostname}/jenkins:1.0"
          image_pull_policy = "Always"

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
      local.common_tags,
      map()
    )}"
    
    name = "jenkins"
    namespace = "${local.namespace}"
  }

  spec {
    type = "LoadBalancer"
    selector {
      app = "jenkins"
    }
    port {
      name = "http"
      port = 80
      target_port = 8080
    }

    port {
      name = "jnlp"
      port = 38339
      target_port = 38339
    }

    load_balancer_source_ranges = [ 
      "50.20.0.62/32",     # Banyan office
      "24.99.117.169/32",  # Ardis Home
      "162.236.22.89/32",  # Mark W Home
      "24.125.218.36/32",  # Benji Home
      "47.187.167.223/32", # Sapience office
      # "0.0.0.0/0",        # Open to the world
      "52.224.108.229/32", # Jenkins Windows Agent / Slave
    ]
  }
}

resource "kubernetes_persistent_volume_claim" "jenkins_home" {
  depends_on = [ "null_resource.jenkins_home_pv" ]
  
  metadata {
    annotations = "${merge(
      local.common_tags,
      map()
    )}"
    
    name = "jenkins"
    namespace = "${local.namespace}"
  }

  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests {
        storage = "10G"
      }
    }
    volume_name = "jenkins-home-${var.realm}"  // This is what it should be when PV is created under TF: "${null_resource.jenkins_home.metadata.0.name}"
    storage_class_name = "${kubernetes_storage_class.jenkins_home.metadata.0.name}"
  }
}

data "template_file" "jenkins_home_pv" {
  template = "${file("templates/jenkins-home-pv.yaml.tpl")}"

  vars {
    realm = "${var.realm}"
    subscription_id = "${var.subscription_id}"
    resource_group_name = "${var.resource_group_name}"
  }
}

resource "null_resource" "jenkins_home_pv" {
  triggers {
    template_changed = "${data.template_file.jenkins_home_pv.rendered}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -f - <<EOF\n${data.template_file.jenkins_home_pv.rendered}\nEOF"
  }

  provisioner "local-exec" {
    when = "destroy"

    command = "kubectl delete --kubeconfig=${local.config_path} persistentvolume jenkins-home-${var.realm}"
  }  
}

resource "kubernetes_storage_class" "jenkins_home" {
  metadata {
    annotations = "${merge(
      local.common_tags,
      map()
    )}"
    
    name = "jenkins"
  }

  storage_provisioner = "kubernetes.io/azure-disk"
  reclaim_policy = "Retain"
  parameters {
    storageaccounttype = "Standard_LRS"
  }
}

resource "kubernetes_persistent_volume_claim" "maven_repo" {
  depends_on = [ "null_resource.maven_repo_pv" ]
  
  metadata {
    annotations = "${merge(
      local.common_tags,
      map()
    )}"
    
    name = "maven-repo"
    namespace = "${local.namespace}"
  }

  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests {
        storage = "20G"
      }
    }
    volume_name = "maven-repo-${var.realm}"  // This is what it should be when PV is created under TF: "${null_resource.maven_repo.metadata.0.name}"
    storage_class_name = "${kubernetes_storage_class.maven_repo.metadata.0.name}"
  }
}

data "template_file" "maven_repo_pv" {
  template = "${file("templates/maven-repo-pv.yaml.tpl")}"

  vars {
    realm = "${var.realm}"
    subscription_id = "${var.subscription_id}"
    resource_group_name = "${var.resource_group_name}"
  }
}

resource "null_resource" "maven_repo_pv" {
  triggers {
    template_changed = "${data.template_file.maven_repo_pv.rendered}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -f - <<EOF\n${data.template_file.maven_repo_pv.rendered}\nEOF"
  }

  provisioner "local-exec" {
    when = "destroy"

    command = "kubectl delete --kubeconfig=${local.config_path} persistentvolume maven-repo-${var.realm}"
  }  
}

resource "kubernetes_storage_class" "maven_repo" {
  metadata {
    annotations = "${merge(
      local.common_tags,
      map()
    )}"
    
    name = "maven-repo"
  }

  storage_provisioner = "kubernetes.io/azure-disk"
  reclaim_policy = "Retain"
  parameters {
    storageaccounttype = "Standard_LRS"
  }
}

resource "kubernetes_service_account" "jenkins" {
  metadata {
    annotations = "${merge(
      local.common_tags,
      map()
    )}"
    
    name = "jenkins"
    namespace = "${local.namespace}"
  }

  # secret {
  #   name = "${kubernetes_secret.example.metadata.0.name}"
  # }
}

resource "kubernetes_cluster_role_binding" "jenkins" {
  metadata {
    annotations = "${merge(
      local.common_tags,
      map()
    )}"
    
    name = "jenkins"
  }

    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "cluster-admin"
    }
    subject {
        kind = "ServiceAccount"
        name = "jenkins"
        namespace = "management"
        api_group = ""
    }
    # subject {
    #     kind = "Group"
    #     name = "system:masters"
    #     api_group = "rbac.authorization.k8s.io"
    # }
}

/* resource "aws_route53_record" "jenkins" {
  provider = "aws.banyan"   # we are going to create this in the "banyan" account, since that is where the banyanhills.com hosted zone is

  zone_id = "Z1X9O792DMWEV4"
  name    = "jenkins-lab"
  type    = "CNAME"
  ttl     = "1"

  # weighted_routing_policy {
  #   weight = 10
  # }

  # set_identifier = "dev"
  records        = [ "${kubernetes_service.jenkins.load_balancer_ingress.0.hostname}" ]
} */

/* resource "azurerm_dns_cname_record" "jenkins" {
  name                = "jenkins"
  zone_name           = "${data.terraform_remote_state.dns.zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = 1
  record              = [ "${kubernetes_service.jenkins.load_balancer_ingress.0.hostname}" ]
} */