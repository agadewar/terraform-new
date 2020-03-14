server:
  dataStorage:
    enabled: "false"
  standalone:
    config: |
      ui = true
      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }
      storage "azure" {
        accountName = "${storage-account}"
        accountKey  = "${account-key}"
        container   = "${container}"
        environment = "AzurePublicCloud"
      }

  resources:
    requests:
      memory: 256Mi
      cpu: 250m
    limits:
      memory: 256Mi
      cpu: 250m
injector:
  resources:
    requests:
      memory: 256Mi
      cpu: 250m
    limits:
      memory: 256Mi
      cpu: 250m
