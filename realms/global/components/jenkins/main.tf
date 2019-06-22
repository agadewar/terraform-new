# See: https://www.blazemeter.com/blog/how-to-setup-scalable-jenkins-on-top-of-a-kubernetes-cluster

terraform {
  backend "azurerm" {
    key = "jenkins.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

provider "kubernetes" {
  config_path = "${local.config_path}"
}

data "terraform_remote_state" "dns" {
  backend = "azurerm"
  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "realm-${var.realm}"
    key                  = "dns.tfstate"
  }
}

data "terraform_remote_state" "jenkins_storage" {
  backend = "azurerm"

  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "realm-${var.realm}"
    key                  = "jenkins-storage.tfstate"
  }
}

data "terraform_remote_state" "ingress-controller" {
  backend = "azurerm"

  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "realm-${var.realm}"
    key                  = "ingress-controller.tfstate"
  }
}

data "terraform_remote_state" "kubernetes" {
  backend = "azurerm"

  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "realm-${var.realm}"
    key                  = "kubernetes.tfstate"
  }
}



/* data "terraform_remote_state" "dns" {
  backend = "azurerm"
  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "realm-${var.realm}"
    key                  = "dns.tfstate"
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
  depends_on = [ "kubernetes_persistent_volume_claim.jenkins_home" ]

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
          image = "${var.sapience_container_registry_hostname}/jenkins:1.4"
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
    type = "ClusterIP"
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
      port = 50000
      target_port = 50000
    }

    # load_balancer_source_ranges = "${var.load_balancer_source_ranges_allowed}"
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

resource "kubernetes_secret" "maven_repo_azure_file" {
  metadata {
    annotations = "${merge(
      local.common_tags,
      map()
    )}"
    
    name = "maven-repo-azure-file"
    namespace = "${local.namespace}"
  }

  data {
    azurestorageaccountname = "${data.terraform_remote_state.jenkins_storage.maven_repo_storage_account_name}"
    azurestorageaccountkey  = "${data.terraform_remote_state.jenkins_storage.maven_repo_storage_account_access_key}"
  }

  # type = "Opaque"
}

                # data "template_file" "maven_repo_azure_file_secret" {
                #   template = "${file("templates/maven-repo-azure-file-secret.yaml.tpl")}"

                #   vars {
                #     azurestorageaccountname = "${data.terraform_remote_state.jenkins_storage.maven_repo_storage_account_name}"
                #     azurestorageaccountkey  = "${data.terraform_remote_state.jenkins_storage.maven_repo_storage_account_access_key}"
                #   }
                # }

                # resource "null_resource" "maven_repo_azure_file_secret" {
                #   triggers {
                #     template_changed = "${data.template_file.maven_repo_azure_file_secret.rendered}"
                #   }

                #   provisioner "local-exec" {
                #     command = "kubectl apply --kubeconfig=${local.config_path} -f - <<EOF\n${data.template_file.maven_repo_azure_file_secret.rendered}\nEOF"
                #   }

                #   provisioner "local-exec" {
                #     when = "destroy"

                #     command = "kubectl delete --kubeconfig=${local.config_path} persistentvolume maven-repo-${var.realm}"
                #   }  
                # }



resource "kubernetes_persistent_volume_claim" "maven_repo" {
  depends_on = [ "null_resource.maven_repo_storage_class", "null_resource.maven_repo_pv" ]
  
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
    storage_class_name = "maven-repo"
  }
}

data "template_file" "maven_repo_pv" {
  template = "${file("templates/maven-repo-pv.yaml.tpl")}"

  vars {
    realm = "${var.realm}"
    subscription_id = "${var.subscription_id}"
    resource_group_name = "${var.resource_group_name}"
    secret_name = "${kubernetes_secret.maven_repo_azure_file.metadata.0.name}"
    share_name = "${data.terraform_remote_state.jenkins_storage.maven_repo_storage_account_name}"
  }
}

resource "null_resource" "maven_repo_pv" {
  depends_on = [ "null_resource.maven_repo_storage_class" ]
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

data "template_file" "maven_repo_storage_class" {
  template = "${file("templates/maven-repo-storage-class.yaml.tpl")}"
}

resource "null_resource" "maven_repo_storage_class" {
  triggers {
    template_changed = "${data.template_file.maven_repo_storage_class.rendered}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -f - <<EOF\n${data.template_file.maven_repo_storage_class.rendered}\nEOF"
  }

  # provisioner "local-exec" {
  #   when = "destroy"

  #   command = "kubectl delete --kubeconfig=${local.config_path} persistentvolume maven-repo-${var.realm}"
  # }  
}

                      # resource "kubernetes_storage_class" "maven_repo" {
                      #   metadata {
                      #     annotations = "${merge(
                      #       local.common_tags,
                      #       map()
                      #     )}"
                          
                      #     name = "maven-repo"
                      #   }
                        
                      #   storage_provisioner = "kubernetes.io/azure-file"
                      # //  reclaim_policy = "Retain"
                      #   parameters {
                      #     storageaccounttype = "Standard_LRS"
                      #   }
                      # }

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

data "azurerm_subnet" "default" {
  name                 = "default"
  virtual_network_name = "${var.resource_group_name}-vnet"
  resource_group_name  = "${var.resource_group_name}"
}

resource "azurerm_public_ip" "jenkins_windows_slave" {
  name                = "jenkins-windows-slave-${var.realm}"
  location            = "East US"
  resource_group_name = "${var.resource_group_name}"
  public_ip_address_allocation   = "Static"
}

resource "azurerm_network_interface" "jenkins_windows_slave_nic" {
  depends_on          = [ "azurerm_public_ip.jenkins_windows_slave", "azurerm_network_security_group.jenkins_windows_slave" ]
  name                = "jenkins-windows-slave-nic-${var.realm}"
  resource_group_name   = "${var.resource_group_name}"
  location              = "${var.resource_group_location}"
  network_security_group_id = "${azurerm_network_security_group.jenkins_windows_slave.id}"

  ip_configuration {
    name                          = "jenkins-windows-slave-${var.realm}"
    subnet_id                     = "${data.azurerm_subnet.default.id}"
    public_ip_address_id          = "${azurerm_public_ip.jenkins_windows_slave.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "jenkins_windows_slave" {
  name = "jenkins-windows-slave-${var.realm}"
  location              = "${var.resource_group_location}"
  resource_group_name   = "${var.resource_group_name}"

  # security_rule {
  #   name = "Allow-AllTraffic-BanyanOffice"
  #   priority = 100
  #   direction = "Inbound"
  #   access = "Allow"
  #   protocol = "*"
  #   source_port_range = "*"
  #   destination_port_range = "*"
  #   source_address_prefix = "50.20.0.62/32"
  #   destination_address_prefix = "*"
  # }
}

resource "azurerm_virtual_machine" "jenkins_windows_slave" {
  depends_on            = [ "azurerm_network_interface.jenkins_windows_slave_nic" ]
  name                  = "jenkins-windows-slave-${var.realm}"
  resource_group_name   = "${var.resource_group_name}"
  location              = "${var.resource_group_location}"
  network_interface_ids = ["${azurerm_network_interface.jenkins_windows_slave_nic.id}"]
  vm_size               = "Standard_D2_v3"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  # This means the Data Disk Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "RS3-Pro"
    version   = "latest"
  }

  storage_os_disk {
    name              = "jenkins-windows-slave-os-${var.realm}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "jenkins-win-slv"
    admin_username = "testadmin2"
    admin_password = "Password1234!"
  }

  os_profile_windows_config {}
}

# resource "helm_release" "nginx_ingress" {
#   depends_on = [ "kubernetes_namespace.namespace" ]

#   name      = "nginx-ingress"
#   namespace = "${local.namespace}"
#   chart     = "stable/nginx-ingress"

#   set {
#     name  = "controller.replicaCount"
#     value = "1"
#   }

#   # See: https://docs.microsoft.com/en-us/azure/aks/ingress-tls
#   # set {
#   #   name  = "controller.nodeSelector.\"beta\\.kubernetes\\.io/os\""
#   #   value = "linux"
#   # }

#   # set {
#   #   name  = "defaultBackend.nodeSelector.\"beta\\.kubernetes\\.io/os\""
#   #   value = "linux"
#   # }

#   set {
#     name  = "controller.service.externalTrafficPolicy"
#     value = "Local"
#   }

#   timeout = 600
# }

# resource "null_resource" "nginx_ingress_controller_ip" {
#   depends_on = [ "helm_release.nginx_ingress" ]
  
#   # triggers = {
#   #   timestamp = "${timestamp()}"
#   # }

#   provisioner "local-exec" {
#     command = "mkdir -p .local && kubectl --kubeconfig ${local.config_path} -n ${local.namespace} get services -o json | jq -j '.items[] | select(.metadata.name == \"nginx-ingress-controller\") | .status .loadBalancer .ingress [0] .ip' > .local/nginx-ingress-controller-ip"
#   }

#   provisioner "local-exec" {
#     when = "destroy"

#     command = "rm -f .local/nginx-ingress-controller-ip"
#   }
# }

# data "local_file" "nginx_ingress_controller_ip" {
#   depends_on = [ "null_resource.nginx_ingress_controller_ip" ]

#   filename = ".local/nginx-ingress-controller-ip"
# }

resource "azurerm_dns_a_record" "jenkins" {
  name                = "jenkins.${var.realm}"
  zone_name           = "${data.terraform_remote_state.dns.sapienceanalytics_public_zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = 30
  records             = [ "${data.terraform_remote_state.ingress-controller.nginx_ingress_controller_ip}" ]
}

resource "kubernetes_ingress" "jenkins" {
  metadata {
    name = "jenkins"
    namespace = "${local.namespace}"

    annotations = {
      "certmanager.k8s.io/acme-challenge-type"             = "dns01"
      "certmanager.k8s.io/acme-dns01-provider"             = "azure-dns"
      "certmanager.k8s.io/issuer"                          = "letsencrypt-prod"
      "ingress.kubernetes.io/ssl-redirect"                 = "true"
      "kubernetes.io/ingress.class"                        = "nginx"
      "kubernetes.io/tls-acme"                             = "true"
      "nginx.ingress.kubernetes.io/whitelist-source-range" = "${join(", ", var.jenkins_source_ranges_allowed)}"
    }
  }

  spec {
    # backend {
    #   service_name = "MyApp1"
    #   service_port = 8080
    # }

    rule {
      host = "jenkins.${var.realm}.sapienceanalytics.com"
      http {
        path {
          backend {
            service_name = "jenkins"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    rule {
      host = "jenkins.sapienceanalytics.com"
      http {
        path {
          backend {
            service_name = "jenkins"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    tls {
      hosts = [ 
        "jenkins.${var.realm}.sapienceanalytics.com",
        "jenkins.sapienceanalytics.com"
      ]
      secret_name = "jenkins-certs"
    }
  }
}

resource "kubernetes_secret" "service_principal_password" {
  metadata {
    name = "service-principal-password"
    namespace = "${local.namespace}"
  }

  data {
    password = "${var.service_principal_password}"
  }
}

data "template_file" "letsencrypt_issuer_staging" {
  template = "${file("templates/letsencrypt-issuer.yaml.tpl")}"

  vars {
    suffix = "-staging"
    letsencrypt_server = "https://acme-staging-v02.api.letsencrypt.org/directory"
    email = "devops@sapience.net"   # TODO !!! Normally, this would come from var.letsencrypt_cluster_issuer_email of the environment tfvars; but this is a realm component, so need to figure this out
    service_principal_client_id = "${var.service_principal_app_id}"
    service_principal_password_secret_ref = "${kubernetes_secret.service_principal_password.metadata.0.name}"
    dns_zone_name = "sapienceanalytics.com"
    resource_group_name = "${var.resource_group_name}"
    subscription_id = "${var.subscription_id}"
    service_pricincipal_tenant_id = "${var.service_principal_tenant}"
  }
}

resource "null_resource" "letsencrypt_issuer_staging" {
  # depends_on = [ "helm_release.cert_manager" ]

  triggers {
    template_changed = "${data.template_file.letsencrypt_issuer_staging.rendered}"
    # timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.letsencrypt_issuer_staging.rendered}\nEOF"
  }
}

data "template_file" "letsencrypt_issuer_prod" {
  template = "${file("templates/letsencrypt-issuer.yaml.tpl")}"

  vars {
    suffix = "-prod"
    letsencrypt_server = "https://acme-v02.api.letsencrypt.org/directory"
    email = "devops@sapience.net"   # TODO !!! Normally, this would come from var.letsencrypt_cluster_issuer_email of the environment tfvars; but this is a realm component, so need to figure this out
    service_principal_client_id = "${var.service_principal_app_id}"
    service_principal_password_secret_ref = "${kubernetes_secret.service_principal_password.metadata.0.name}"
    dns_zone_name = "sapienceanalytics.com"
    resource_group_name = "${var.resource_group_name}"
    subscription_id = "${var.subscription_id}"
    service_pricincipal_tenant_id = "${var.service_principal_tenant}"
  }
}

resource "null_resource" "letsencrypt_issuer_prod" {
  # depends_on = [ "helm_release.cert_manager" ]

  triggers {
    template_changed = "${data.template_file.letsencrypt_issuer_prod.rendered}"
    # timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.letsencrypt_issuer_prod.rendered}\nEOF"
  }
}