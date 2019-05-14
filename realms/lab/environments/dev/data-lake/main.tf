terraform {
  backend "azurerm" {
    key = "sapience.environment.dev.data-lake.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

locals {
  common_tags = "${merge(
    var.realm_common_tags,
    var.environment_common_tags,
    map(
      "Component", "Data Lake"
    )
  )}"
}






# resource "azurerm_data_lake_store" "sapience" {
#   name                = "sapience${var.environment}"
#   resource_group_name = "${var.resource_group_name}"
#   location            = "eastus2"
#   encryption_state    = "Enabled"
#   encryption_type     = "ServiceManaged"

#   tags = "${merge(
#     local.common_tags,
#     map()
#   )}"
# }

# resource "azurerm_data_lake_store_firewall_rule" "ardis_home" {
#   name                = "ardis-home"
#   account_name        = "${azurerm_data_lake_store.sapience.name}"
#   resource_group_name = "${var.resource_group_name}"
#   start_ip_address    = "24.99.117.169"
#   end_ip_address      = "24.99.117.169"
# }

# resource "azurerm_data_lake_store_firewall_rule" "banyan" {
#   name                = "banyan"
#   account_name        = "${azurerm_data_lake_store.sapience.name}"
#   resource_group_name = "${var.resource_group_name}"
#   start_ip_address    = "50.20.0.62"
#   end_ip_address      = "50.20.0.62"
# }







resource "null_resource" "azure_data_lake_storage_gen2" {
  # triggers = {
  #   manifest_sha1 = "${sha1("${file("files/ambassador-rbac.yaml")}")}"
  #   timestamp = "${timestamp()}"   # DELETE ME
  # }

  # See: https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction?toc=%2fazure%2fstorage%2fblobs%2ftoc.json
  # See: https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-quickstart-create-account
  # !!! To interact with Data Lake Storage Gen2 by using the CLI, you'll have to add an extension to your shell... "az extension add --name storage-preview"
  provisioner "local-exec" {
    # command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f -<<EOF\n${file("files/ambassador-rbac.yaml")}\nEOF"
    command = "az storage account create --name sapiencedatalake${var.environment} --subscription ${var.subscription_id} --resource-group ${var.resource_group_name} --location ${var.resource_group_location} --sku Standard_LRS --kind StorageV2 --hierarchical-namespace true"
  }

  provisioner "local-exec" {
    when = "destroy"

    command = "az storage account delete --name sapiencedatalake${var.environment} --subscription ${var.subscription_id} --resource-group ${var.resource_group_name} --yes"
  }
}

# resource "azurerm_storage_container" "raw-data" {
#   name                  = "raw-data"
#   resource_group_name   = "${var.resource_group_name}"
#   storage_account_name  = "sapiencedatalake${var.environment}"
#   container_access_type = "private"
# }
