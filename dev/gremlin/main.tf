terraform {
  backend "azurerm" {
    access_key           = "OPAUji+E5XV9vXAouVK5wt7u2ZTfdvVdifj8dUmOcRq9WGjQe5cyciqPZ23ZaffW1P5/GE29OzvLfhmUjl3HQg=="
    storage_account_name = "terraformstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.dev.gremlin.terraform.tfstate"
  }
}

provider "kubernetes" {
  config_path = "../../lab/kubernetes/kubeconfig"
}

locals {
  namespace = "dev"

  common_labels = {
    "app.kubernetes.io/customer"    = "Sapience"
	  "app.kubernetes.io/product"     = "Sapience"
	  "app.kubernetes.io/environment" = "Dev"
	  "app.kubernetes.io/component"   = "Gremlin"
	  "app.kubernetes.io/managed-by"  = "Terraform"
  }
}
resource "kubernetes_deployment" "gremlin" {
  metadata {
    name = "gremlin"
    namespace = "${local.namespace}"

    labels = "${merge(
      local.common_labels,
      map(
        "app.kubernetes.io/name", "gremlin"
      )
    )}"
  }

  spec {
    replicas = "1"

    selector {
      match_labels {
        "app.kubernetes.io/name" = "gremlin"
      }
    }

    template {
      metadata {
        labels = "${merge(
          local.common_labels,
          map(
            "app.kubernetes.io/name", "gremlin"
          )
        )}"
      }

      spec {
        container {
          # See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
          image = "tinkerpop/gremlin-server:3.2.11"
          name  = "gremlin"
        }
      }
    }
  }
}

resource "kubernetes_service" "gremlin" {
  metadata {
    labels = "${merge(
      local.common_labels,
      map(
        "app.kubernetes.io/name", "gremlin"
      )
    )}"

    name = "gremlin"
    namespace = "${local.namespace}"
  }

  spec {
    type = "LoadBalancer"
    selector {
      "app.kubernetes.io/name" = "gremlin"
    }

    port {
      port = 8182
    }

    load_balancer_source_ranges = [
      "50.20.0.62/32",     # Banyan office
      "24.99.117.169/32",  # Ardis home
      "47.187.167.223/32"  # Sapience office
    ]
  }
}
