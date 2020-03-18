### sapience.net
resource "azurerm_dns_a_record" "sapience_public" {
  name                = "@"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  records             = ["107.180.24.243"]
}

# resource "azurerm_dns_a_record" "sapience_demo" {
#   name                = "demo"
#   zone_name           = "${azurerm_dns_zone.sapience_public.name}"
#   resource_group_name = "${var.resource_group_name}"  # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
#   ttl                 = 300
#   records             = ["40.117.158.54"]
# }

# resource "azurerm_dns_a_record" "sapience_draco" {
#   name                = "draco"
#   zone_name           = "${azurerm_dns_zone.sapience_public.name}"
#   resource_group_name = "${var.resource_group_name}"  # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
#   ttl                 = 300
#   records             = ["40.122.111.10"]
# }

resource "azurerm_dns_a_record" "sapience_earth" {
  name                = "earth"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  records             = ["103.224.243.206"]
}

resource "azurerm_dns_a_record" "sapience_galaxy" {
  name                = "galaxy"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  records             = ["103.228.152.113"]
}

resource "azurerm_dns_a_record" "sapience_world" {
  name                = "world"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  records             = ["66.7.149.26"]
}

resource "azurerm_dns_a_record" "sapience_kc" {
  name                = "kc"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  records             = ["50.17.217.186"]
}

resource "azurerm_dns_a_record" "sapience_neptune" {
  name                = "neptune"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  records             = ["216.87.170.240"]
}

resource "azurerm_dns_a_record" "sapience_nova" {
  name                = "nova"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  records             = ["13.90.85.24"]
}

resource "azurerm_dns_a_record" "sapience_test" {
  name                = "test"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  records             = ["45.123.144.160"]
}

resource "azurerm_dns_a_record" "sapience_artofworking" {
  name                = "artofworking"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  records             = ["199.116.77.52"]
}

# resource "azurerm_dns_a_record" "sisense_dev" {
#   name                = "sisense.dev"
#   zone_name           = "${azurerm_dns_zone.sapience_public.name}"
#   resource_group_name = "${var.resource_group_name}"  # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
#   ttl                 = 300
#   records             = ["52.234.226.40"]
# }

####################

### sapienceanalytics.com
resource "azurerm_dns_a_record" "sapienceanalytics_public" {
  name                = "@"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  records             = ["3.21.38.221"]
}

resource "azurerm_dns_a_record" "sapienceanalytics_dev_public" {
  name                = "www.dev"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  records             = ["3.17.111.37"]
}

resource "azurerm_dns_a_record" "sapienceanalytics_staging_public" {
  name                = "www.staging"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  records             = ["3.21.38.221"]
}

### sapienceu.com
resource "azurerm_dns_a_record" "sapienceu_public" {
  name                = "@"
  zone_name           = "sapienceu.com"
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  records             = ["54.88.17.160"]
}

