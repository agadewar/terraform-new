terraform {
  backend "azurerm" {
    key = "data-lake.tfstate"
  }
}

provider "azurerm" {
  version = "1.31.0"
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
    command = "az storage account create --name sapdl${replace(lower(var.realm), "-", "")}${var.environment} --subscription ${var.subscription_id} --resource-group ${var.resource_group_name} --location ${var.resource_group_location} --sku Standard_ZRS --kind StorageV2 --hierarchical-namespace true"
  }

  provisioner "local-exec" {
    when = "destroy"

    command = "az storage account delete --name sapdl${replace(lower(var.realm), "-", "")}${var.environment} --subscription ${var.subscription_id} --resource-group ${var.resource_group_name} --yes"
  }
}

resource "null_resource" "azure_data_lake_storage_gen2_key_1" {
  depends_on = [ null_resource.azure_data_lake_storage_gen2 ]

  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = "mkdir -p .local && az storage account keys list --account-name sapdl${replace(lower(var.realm), "-", "")}${var.environment} --subscription ${var.subscription_id} --resource-group ${var.resource_group_name} | jq -r .[0].value > .local/azure_data_lake_storage_gen2.key1"
  }
}

data "local_file" "azure_data_lake_storage_gen2_key_1" {
  depends_on = [ "null_resource.azure_data_lake_storage_gen2_key_1" ]

  filename = ".local/azure_data_lake_storage_gen2.key1"
}

resource "null_resource" "azure_data_lake_storage_gen2_key_2" {
  depends_on = [ null_resource.azure_data_lake_storage_gen2 ]

  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = "mkdir -p .local && az storage account keys list --account-name sapdl${replace(lower(var.realm), "-", "")}${var.environment} --subscription ${var.subscription_id} --resource-group ${var.resource_group_name} | jq -r .[1].value > .local/azure_data_lake_storage_gen2.key2"
  }
}

data "local_file" "azure_data_lake_storage_gen2_key_2" {
  depends_on = [ "null_resource.azure_data_lake_storage_gen2_key_2" ]

  filename = ".local/azure_data_lake_storage_gen2.key2"
}
