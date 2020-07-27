terraform {
  backend "azurerm" {
    key = "vm.tfstate"
  }
}
