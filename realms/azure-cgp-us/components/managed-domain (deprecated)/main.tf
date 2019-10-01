##########################################################
# SUMMARY
# - Deploy Azure AD Domain Services through a ARM Template
# - Requires AZ CLI (az login) to be run before tfapply
# - User must be a tenant admin before running tfapply
##########################################################

#########################################
# TERRAFROM REMOTE STATE - (READ / WRITE)
#########################################
terraform {
  backend "azurerm" {
    key = "domain.tfstate"
  }
}

##############################################
# AZURE PLUGIN
# - Authentication throguh AZ CLI
# - Requires az login to be run before tfapply
##############################################
provider "azurerm" {
  version         = "1.34.0"
  
  subscription_id = var.subscription_id
  tenant_id       = var.service_principal_tenant
}

#################
# LOCAL VARIABLES
#################
locals {
  resource_name = "${var.realm}-aaddds" 
  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Network"
    },
  )
}

#####################
# DEPLOY ARM TEMPLATE
#####################
resource "azurerm_template_deployment" "managed-domain" {
  name                = "101-AAD-DomainServices"
  resource_group_name = var.resource_group_name

  template_body = <<DEPLOY
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "domainName": {
            "type": "string",
            "metadata": {
                "description": "Domain Name"
            }
        },
        "location": {
            "type": "string",
            "defaultValue": "[resourceGroup().location]",
            "metadata": {
                "description": "Location for all resources."
            }
        },
        "domainServicesVnetName": {
            "type": "string",
            "defaultValue": "domain-services-vnet",
            "metadata": {
                "description": "Virtual Network Name"
            }
        },
        "domainServicesVnetAddressPrefix": {
            "type": "string",
            "defaultValue": "10.0.0.0/16",
            "metadata": {
                "description": "Address Prefix"
            }
        },
        "domainServicesSubnetName": {
            "type": "string",
            "defaultValue": "domain-services-subnet",
            "metadata": {
                "description": "Virtual Network Name"
            }
        },
        "domainServicesSubnetAddressPrefix": {
            "type": "string",
            "defaultValue": "10.0.0.0/24",
            "metadata": {
                "description": "Subnet prefix"
            }
        }
    },
    "variables": {
        "domainServicesNSGName": "${local.resource_name}",
        "nsgRefId": "[resourceId('Microsoft.Network/networkSecurityGroups', variables('domainServicesNSGName'))]",
        "vnetRefId": "[resourceId('Microsoft.Network/virtualNetworks/', parameters('domainServicesVnetName'))]",
        "subnetRefId": "[resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('domainServicesVnetName'), parameters('domainServicesSubnetName'))]",
        "PSRemotingSlicePIPAddresses": [
            "52.180.179.108",
            "52.180.177.87",
            "13.75.105.168",
            "52.175.18.134",
            "52.138.68.41",
            "52.138.65.157",
            "104.41.159.212",
            "104.45.138.161",
            "52.169.125.119",
            "52.169.218.0",
            "52.187.19.1",
            "52.187.120.237",
            "13.78.172.246",
            "52.161.110.169",
            "52.174.189.149",
            "40.68.160.142",
            "40.83.144.56",
            "13.64.151.161"
        ],
        "RDPIPAddresses": [
            "207.68.190.32/27",
            "13.106.78.32/27",
            "13.106.174.32/27",
            "13.106.4.96/27"
        ],
        "PSRemotingSliceTIPAddresses": [
            "52.180.183.67",
            "52.180.181.39",
            "52.175.28.111",
            "52.175.16.141",
            "52.138.70.93",
            "52.138.64.115",
            "40.80.146.22",
            "40.121.211.60",
            "52.138.143.173",
            "52.169.87.10",
            "13.76.171.84",
            "52.187.169.156",
            "13.78.174.255",
            "13.78.191.178",
            "40.68.163.143",
            "23.100.14.28",
            "13.64.188.43",
            "23.99.93.197"
        ]
    },
    "resources": [
        {
            "apiVersion": "2018-10-01",
            "type": "Microsoft.Network/networkSecurityGroups",
            "name": "[variables('domainServicesNSGName')]",
            "location": "[parameters('location')]",
            "properties": {
                "securityRules": [
                    {
                        "name": "AllowPSRemotingSliceP",
                        "properties": {
                            "protocol": "Tcp",
                            "sourcePortRange": "*",
                            "destinationPortRange": "5986",
                            "sourceAddressPrefixes": "[variables('PSRemotingSlicePIPAddresses')]",
                            "destinationAddressPrefix": "*",
                            "access": "Allow",
                            "priority": 301,
                            "direction": "Inbound"
                        }
                    },
                    {
                        "name": "AllowRDP",
                        "properties": {
                            "protocol": "Tcp",
                            "sourcePortRange": "*",
                            "destinationPortRange": "3389",
                            "sourceAddressPrefixes": "[variables('RDPIPAddresses')]",
                            "destinationAddressPrefix": "*",
                            "access": "Allow",
                            "priority": 201,
                            "direction": "Inbound"
                        }
                    },
                    {
                        "name": "AllowSyncWithAzureAD",
                        "properties": {
                            "protocol": "Tcp",
                            "sourcePortRange": "*",
                            "destinationPortRange": "443",
                            "sourceAddressPrefix": "*",
                            "destinationAddressPrefix": "*",
                            "access": "Allow",
                            "priority": 101,
                            "direction": "Inbound"
                        }
                    },
                    {
                        "name": "AllowPSRemotingSliceT",
                        "properties": {
                            "protocol": "Tcp",
                            "sourcePortRange": "*",
                            "destinationPortRange": "5986",
                            "sourceAddressPrefixes": "[variables('PSRemotingSliceTIPAddresses')]",
                            "destinationAddressPrefix": "*",
                            "access": "Allow",
                            "priority": 302,
                            "direction": "Inbound"
                        }
                    }
                ]
            }
        },
        {
            "apiVersion": "2018-10-01",
            "type": "Microsoft.Network/virtualNetworks",
            "name": "[parameters('domainServicesVnetName')]",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[variables('domainServicesNSGName')]"
            ],
            "properties": {
                "addressSpace": {
                    "addressPrefixes": [
                        "[parameters('domainServicesVnetAddressPrefix')]"
                    ]
                }
            },
            "resources": [
                {
                    "apiVersion": "2018-10-01",
                    "type": "subnets",
                    "location": "[parameters('location')]",
                    "name": "[parameters('domainServicesSubnetName')]",
                    "dependsOn": [
                        "[parameters('domainServicesVnetName')]"
                    ],
                    "properties": {
                        "addressPrefix": "[parameters('domainServicesSubnetAddressPrefix')]",
                        "networkSecurityGroup": {
                            "id": "[variables('nsgRefId')]"
                        }
                    }
                }
            ]
        },
        {
            "type": "Microsoft.AAD/DomainServices",
            "name": "[parameters('domainName')]",
            "apiVersion": "2017-06-01",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[parameters('domainServicesVnetName')]"
            ],
            "properties": {
                "domainName": "[parameters('domainName')]",
                "vnetSiteID": "[variables('vnetRefId')]",
                "subnetId": "[variables('subnetRefId')]"
            }
        }
    ],
    "outputs": {}
}
DEPLOY

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    "domainName"                        = "sapience.net"
    "location"                          = "eastus2"
    "domainServicesVnetName"            = "cgp-us"
    "domainServicesVnetAddressPrefix"   = "10.106.0.0/16"
    "domainServicesSubnetName"          = "domain"
    "domainServicesSubnetAddressPrefix" = "10.106.4.0/22"
  }

  deployment_mode = "Incremental"
}