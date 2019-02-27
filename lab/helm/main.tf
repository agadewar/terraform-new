terraform {
  backend "azurerm" {
    access_key           = "f6c42IJmnIymEm3ziDX2GdgrrqUVNSV82CX5/2LWcrc4bwHnCJWhPHHzQFRaQqoLLjZIle9+BsfFguI4epFNeA=="
    storage_account_name = "sapiencetfstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.lab.helm.terraform.tfstate"
  }
}

provider "kubernetes" {
    config_path = "${local.config_path}"
}

provider "helm" {
  kubernetes {
    config_path = "${local.config_path}"
  }

  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
}



locals {
  config_path = "../kubernetes/kubeconfig"

  common_tags = {
    Customer = "Sapience"
    Product = "Sapience"
    Environment = "Lab"
    Component = "Helm"
    ManagedBy = "Terraform"
  }
}


/* resource "null_resource" "cronjob_canopy_container_registry_credential_helper" {

  triggers {
    config_changed = "${sha1(file("./config/canopy-container-registry-credential-helper.yaml"))}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=../../lab/kubernetes/kubeconfig -f ./config/canopy-container-registry-credential-helper.yaml"
  }
}
 */



 resource "kubernetes_service_account" "tiller" {
  metadata {
    annotations {
      Customer = "Banyan"
      Product = "Global"
      Environment = "Lab"
      ManagedBy = "Terraform"
    }

    name = "tiller"
    namespace = "kube-system"
  }
  # secret {
  #   name = "${kubernetes_secret.example.metadata.0.name}"
  # }
}

# See: https://stackoverflow.com/questions/46672523/helm-list-cannot-list-configmaps-in-the-namespace-kube-system
# See: https://github.com/helm/helm/issues/3460
resource "kubernetes_cluster_role_binding" "tiller_cluster_rule" {
    depends_on = [ "kubernetes_service_account.tiller" ]

    metadata {
      annotations {
        Customer = "Banyan"
        Product = "Global"
        Environment = "Lab"
        ManagedBy = "Terraform"
        }
      
      name = "tiller-cluster-rule"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "cluster-admin"
    }
    subject {
        kind = "ServiceAccount"
        name = "tiller"
        namespace = "kube-system"
        api_group = ""
    }
    # subject {
    #     kind = "Group"
    #     name = "system:masters"
    #     api_group = "rbac.authorization.k8s.io"
    # }
}

# resource "null_resource" "tiller_deploy_patch" {
#   depends_on = [ "kubernetes_cluster_role_binding.tiller_cluster_rule" ]
#   provisioner "local-exec" {
#     command = "kubectl --kubeconfig ../eks/kubeconfig_banyan-global-lab-eks-cluster patch deploy --namespace kube-system tiller-deploy -p '{\"spec\":{\"template\":{\"spec\":{\"serviceAccount\":\"tiller\"}}}}'"
#     #command = "kubectl --kubeconfig ../eks/kubeconfig_banyan-global-lab-eks-cluster patch deploy --namespace kube-system tiller-deploy -p '{\"spec\":{\"template\":{\"spec\":{\"serviceAccount\":\"tiller\", \"automountServiceAccountToken\":true}}}}'"
#   }

#   provisioner "local-exec" {
#     command = "kubectl --kubeconfig ../eks/kubeconfig_banyan-global-lab-eks-cluster patch deploy --namespace kube-system tiller-deploy -p '{\"spec\":{\"template\":{\"spec\":{\"automountServiceAccountToken\":true}}}}'"
#   }
# }

resource "null_resource" "helm_init" {
  # depends_on = [ "null_resource.tiller_deploy_patch" ]
  depends_on = [ "kubernetes_cluster_role_binding.tiller_cluster_rule" ]
  
  provisioner "local-exec" {
    command = "helm --kubeconfig ${local.config_path} init --service-account tiller --automount-service-account-token --upgrade"
  }
}


