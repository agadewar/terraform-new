terraform {
  backend "azurerm" {
    key                  = "sapience.dev.ambassador.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${local.subscription_id}"
}

provider "helm" {
  kubernetes {
    config_path = "${local.config_path}"
  }

  #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  service_account = "tiller"

}

provider "kubernetes" {
    config_path = "${local.config_path}"
}

data "terraform_remote_state" "resource_group" {
  backend = "azurerm"
  config {
    access_key           = "${local.backend_access_key}"
    storage_account_name = "${local.backend_storage_account_name}"
	  container_name       = "${local.backend_container_name}"
    key                  = "sapience.lab.resource-group.terraform.tfstate"
  }
}

data "terraform_remote_state" "dns" {
  backend = "azurerm"
  config {
    access_key           = "${local.backend_access_key}"
    storage_account_name = "${local.backend_storage_account_name}"
	  container_name       = "${local.backend_container_name}"
    key                  = "sapience.dev.dns.terraform.tfstate"
  }
}

locals {
  environment          = "${var.environment}"
  subscription_id      = "${var.subscription_id}"
  backend_access_key   = "${var.backend_access_key}"
  backend_storage_account_name = "${var.backend_storage_account_name}"
  backend_container_name       = "${var.backend_container_name}"
  resource_group_name  = "${data.terraform_remote_state.resource_group.resource_group_name}"
  config_path = "../../lab/kubernetes/kubeconfig"
  namespace = "dev"
  letsencrypt_email = "${var.letsencrypt_email}"
  letsencrypt_acme_http_domain = "${var.letsencrypt_acme_http_domain}"
  letsencrypt_acme_http_token  = "${var.letsencrypt_acme_http_token}"

  
  common_tags = "${merge(
    var.common_tags,
      map(
        "Component", "Ambassador"
      )
  )}"
}

# See: https://www.getambassador.io/user-guide/getting-started/#1-deploying-ambassador
resource "null_resource" "ambassador_rbac" {
  triggers = {
    manifest_sha1 = "${sha1("${file("files/ambassador-rbac.yaml")}")}"
    timestamp = "${timestamp()}"   # DELETE ME
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n dev -f -<<EOF\n${file("files/ambassador-rbac.yaml")}\nEOF"
  }
}

# See: https://www.getambassador.io/user-guide/getting-started/#2-defining-the-ambassador-service
resource "kubernetes_service" "ambassador" {
  metadata {
    name = "ambassador"
    namespace = "${local.namespace}"

    annotations {
      "getambassador.io/config" = <<EOF
---
apiVersion: ambassador/v1
kind: Module
name: tls
config:
  server:
    enabled: True
    redirect_cleartext_from: 80
    secret: ambassador-certs
EOF
    }
  }

  spec {
    selector {
      service = "ambassador"
    }

    port {
      name = "http"
      port = 80
    }

    port {
      name = "https"
      port = 443
    }

    # See: https://github.com/terraform-providers/terraform-provider-kubernetes/pull/59
    # Note: Due to issue above, use "null_resource.patch_ambassador_service" to patch the "externalTrafficPolicy" property
    # external_traffic_policy = "Local"
    
    type = "LoadBalancer"
  }
}

# See: https://www.getambassador.io/user-guide/getting-started/#2-defining-the-ambassador-service
# See: https://github.com/terraform-providers/terraform-provider-kubernetes/pull/59
resource "null_resource" "patch_ambassador_service" {
  depends_on = [ "kubernetes_service.ambassador" ]

  triggers {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl patch --kubeconfig=${local.config_path} svc ambassador -n ${local.namespace} -p '{\"spec\":{\"externalTrafficPolicy\":\"Local\"}}'"
  }
}

# See: https://www.getambassador.io/user-guide/getting-started/#5-adding-a-service
resource "kubernetes_service" "api" {
  metadata {
    name = "api"
    namespace = "${local.namespace}"
    annotations {
      "getambassador.io/config" = <<EOF
---
apiVersion: ambassador/v1
kind:  Mapping
name:  canopy_device_service_mapping
prefix: /device/
service: canopy-device-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  canopy_hierarchy_service_mapping
prefix: /hierarchy/
service: canopy-hierarchy-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  canopy_user_service_mapping
prefix: /user/
service: canopy-user-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  eventpipeline_leaf_broker_mapping
prefix: /leafbroker/
service: eventpipeline-leaf-broker
---
apiVersion: ambassador/v1
kind:  Mapping
name:  eventpipeline_service_mapping
prefix: /eventpipeline/
service: eventpipeline-service
EOF
    }
  }

  spec {
    port {
      name = "http"
      port = 80
    }
  }
}

resource "azurerm_dns_a_record" "api" {
  name                = "api"
  zone_name           = "${data.terraform_remote_state.dns.zone_name}"
  resource_group_name = "${local.resource_group_name}"
  ttl                 = 30
  records             = [ "${kubernetes_service.ambassador.load_balancer_ingress.0.ip}" ]
}

# See: https://www.getambassador.io/user-guide/cert-manager
# See: https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
resource "null_resource" "create_cert_manager_crd" {
  triggers {
    manifest_sha1 = "${sha1("${file("files/cert-manager-crds.yaml")}")}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f -<<EOF\n${file("files/cert-manager-crds.yaml")}\nEOF"
  }
}

resource "helm_release" "cert_manager" {
  depends_on = [ "null_resource.create_cert_manager_crd" ]

  name       = "cert-manager"
  namespace  = "${local.namespace}"
  chart      = "stable/cert-manager"
  
  set {
    name  = "webhook.enabled"
    value = "false"
  }

  set {
    name  = "resources.requests.cpu"
    value = "10m"
  }

  set {
    name  = "resources.requests.memory"
    value = "32Mi"
  }
}

# See: https://www.getambassador.io/user-guide/cert-manager
data "template_file" "letsencrypt_cluster_issuer" {
  template = "${file("templates/letsencrypt-cluster-issuer.yaml.tpl")}"

  vars {
     email = "${local.letsencrypt_email}"
  }
}

resource "null_resource" "letsencrypt_cluster_issuer" {
  depends_on = ["helm_release.cert_manager"]

  triggers {
    template_changed = "${data.template_file.letsencrypt_cluster_issuer.rendered}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=../../lab/kubernetes/kubeconfig -n ${local.namespace} -f - <<EOF\n${data.template_file.letsencrypt_cluster_issuer.rendered}\nEOF"
  }
}

# See: https://www.getambassador.io/user-guide/cert-manager
data "template_file" "letsencrypt_certificate" {
  template = "${file("templates/letsencrypt-certificate.yaml.tpl")}"

  vars {
     namespace = "${local.namespace}"
  }
}

resource "null_resource" "letsencrypt_certificate" {
  depends_on = ["helm_release.cert_manager"]

  triggers {
    template_changed = "${data.template_file.letsencrypt_certificate.rendered}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=../../lab/kubernetes/kubeconfig -n ${local.namespace} -f - <<EOF\n${data.template_file.letsencrypt_certificate.rendered}\nEOF"
  }
}

# See: https://www.getambassador.io/user-guide/cert-manager
data "template_file" "letsencrypt_acme_challenge_service" {
  template = "${file("templates/letsencrypt-acme-challenge-service.yaml.tpl")}"

  vars {
    acme_http_domain = "${local.letsencrypt_acme_http_domain}"
    acme_http_token  = "${local.letsencrypt_acme_http_token}"
  }
}

resource "null_resource" "letsencrypt_acme_challenge_service" {
  depends_on = ["helm_release.cert_manager"]

  triggers {
    template_changed = "${data.template_file.letsencrypt_acme_challenge_service.rendered}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=../../lab/kubernetes/kubeconfig -n ${local.namespace} -f - <<EOF\n${data.template_file.letsencrypt_acme_challenge_service.rendered}\nEOF"
  }
}