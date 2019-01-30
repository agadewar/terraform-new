terraform {
  backend "azurerm" {
    access_key           = "gx3N29hLwW2OC+kO5FaAedBpjlh83kY35dpOrJZvdYAB+1CG5iHm85/763rJCiEZ6CY+cwSq+ZAVOvK8f2o4Hg=="
    storage_account_name = "terraformstatesapience"
	  container_name       = "tfstate"
    key                  = "sapience.dev2.gremlin.terraform.tfstate"
  }
}

provider "kubernetes" {
  config_path = "../../lab/kubernetes/kubeconfig"
}

locals {
  namespace = "dev2"

  common_tags = {
    Customer    = "Sapience"
	  Product     = "Sapience"
	  Environment = "Dev2"
	  Component   = "Gremlin"
	  ManagedBy   = "Terraform"
  }
}
resource "kubernetes_deployment" "gremlin" {
  metadata {
    name = "gremlin"
    namespace = "${local.namespace}"

    annotations = "${merge(
      local.common_tags,
      map()
    )}"
    
    labels {
	    app = "gremlin"
    }
  }

  spec {
    replicas = "1"

    selector {
      match_labels {
        app = "gremlin"
      }
    }

    template {
      metadata {
        labels {
          app = "gremlin"
        }
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
    annotations = "${merge(
      local.common_tags,
      map()
    )}"
    
    name = "gremlin"
    namespace = "${local.namespace}"
  }

  spec {
    type = "LoadBalancer"
    selector {
      app = "gremlin"
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
