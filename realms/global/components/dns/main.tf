terraform {
  backend "azurerm" {
    key = "dns.tfstate"
  }
}

provider "azurerm" {
  version = "1.31.0"
  
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.service_principal_app_id}"
  client_secret   = "${var.service_principal_password}"
  tenant_id       = "${var.service_principal_tenant}"
}

locals {
  resource_group_name = "${var.resource_group_name}"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "DNS"
    )
  )}"
}

resource "azurerm_role_assignment" "dns_zone_contributor_terraform_sandbox" {
  count = length(var.dns_contributor_role_assignment_ids)

  scope                = "${azurerm_dns_zone.sapienceanalytics_public.id}"
  role_definition_name = "DNS Zone Contributor"
  principal_id         = "${var.dns_contributor_role_assignment_ids[count.index]}"
}

resource "azurerm_dns_zone" "sapienceanalytics_public" {
  name                = "sapienceanalytics.com"
  resource_group_name = "${var.resource_group_name}" 
  zone_type           = "Public"
}

resource "azurerm_dns_zone" "sapienceinsider_public" {
  name                = "sapienceinsider.com"
  resource_group_name = "${var.resource_group_name}"  
  zone_type           = "Public"
}

resource "azurerm_dns_a_record" "sapienceanalytics_public" {
  name                = "@"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"  # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  records             = ["162.241.235.230"]
}

resource "azurerm_dns_mx_record" "sapienceanalytics_public" {
  name                = "@"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = 3600

  record {
    preference = 10
    exchange   = "sapienceanalytics-com.mail.protection.outlook.com"
  }
  tags = {
    Environment = "Production"
  }
}

resource "azurerm_dns_txt_record" "sapienceanalytics_txt" {
  name                = "@"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}" 
  ttl                 = 3600

  record {
    value = "ZOOM_verify_dfZ_gWR7RH6qeRrXntvOpA"
             
  }
  record {
    value = "v=spf1 include: _spf.sendergen.com include: spf.protection.outlook.com -all"
  }
  record {
    value = "sapienceanalytics.azurewebsites.net"
  }
}

resource "azurerm_dns_srv_record" "_sip" {
  name                = "_sip._tls"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}" 
  ttl                 = 3600

  record {
    priority = 100
    weight   = 1
    port     = 443
    target   = "sipdir.online.lync.com"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_dns_srv_record" "_sipfederationtls" {
  name                = "_sipfederationtls._tcp"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}" 
  ttl                 = 3600

  record {
    priority = 100
    weight   = 1
    port     = 5061
    target   = "sipfed.online.lync.com"
  }

  tags = {
    Environment = "Production"
  }
}

#OpenSense Records
resource "azurerm_dns_cname_record" "whs" {
  name                = "smart"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "whs.sendergen.com"
}

resource "azurerm_dns_cname_record" "selector1" {
  name                = "selector1._domainkey"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "selector1-sapienceanalytics-com._domainkey.sapienceana.onmicrosoft.com"
}


resource "azurerm_dns_cname_record" "login-dev" {
  name                = "login.dev"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "dev-piin5umt-cd-iska51tgwdkuwkl8.edge.tenants.auth0.com"
}

resource "azurerm_dns_cname_record" "selector2" {
  name                = "selector2._domainkey"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "selector2-sapienceanalytics-com._domainkey.sapienceana.onmicrosoft.com"
}

resource "azurerm_dns_cname_record" "autodiscover" {
  name                = "autodiscover"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "autodiscover.outlook.com"
}

resource "azurerm_dns_cname_record" "sip" {
  name                = "sip"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "sipdir.online.lync.com"
}

resource "azurerm_dns_cname_record" "lyncdiscover" {
  name                = "lyncdiscover"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "webdir.online.lync.com"
}

resource "azurerm_dns_cname_record" "enterpriseregistration" {
  name                = "enterpriseregistration"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "enterpriseregistration.windows.net"
}

resource "azurerm_dns_cname_record" "enterpriseenrollment" {
  name                = "enterpriseenrollment"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "enterpriseenrollment.manage.microsoft.com"
}

resource "azurerm_dns_cname_record" "api_dev" {
  name                = "api.dev"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "api.dev.lab.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "jenkins" {
  name                = "jenkins"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "jenkins.global.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "portal_dev" {
  name                = "portal.dev"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "portal.dev.lab.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "portal_demo" {
  name                = "portal.demo"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "portal.demo.prod.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "storybook" {
  name                = "storybook"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "storybook.dev.lab.sapienceanalytics.com"
} 

resource "azurerm_dns_cname_record" "storybook_dev" {
  name                = "storybook.dev"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "storybook.dev.lab.sapienceanalytics.com"
}

#This is a temporary record because storybook will only exist in dev - MH
resource "azurerm_dns_cname_record" "storybook_demo" {
  name                = "storybook.demo"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "storybook.demo.prod.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "spinnaker" {
  name                = "spinnaker"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "spinnaker.global.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "sisense_dev" {
  name                = "sisense.dev"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "sisense.dev.lab.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "sisense_build_dev" {
  name                = "sisense-build.dev"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "sisense-build.dev.lab.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "sisense_qa" {
  name                = "sisense.qa"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "sisense.qa.lab.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "sisense_build_qa" {
  name                = "sisense-build.qa"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "sisense-build.qa.lab.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "sonarqube" {
  name                = "sonarqube"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "sonarqube.global.sapienceanalytics.com"
}
