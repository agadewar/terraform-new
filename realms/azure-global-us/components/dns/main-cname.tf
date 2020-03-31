### sapience.net
resource "azurerm_dns_cname_record" "sapience_www_public" {
  name                = "www"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "sapience.net"
}

resource "azurerm_dns_cname_record" "sapience_click" {
  name                = "click"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "go.transfersecure.net"
}

resource "azurerm_dns_cname_record" "sapience_em" {
  name                = "em"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "u284005.wl006.sendgrid.net"
}

resource "azurerm_dns_cname_record" "sapience_s1_domainkey" {
  name                = "s1._domainkey"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "s1.domainkey.u284005.wl006.sendgrid.net"
}

resource "azurerm_dns_cname_record" "sapience_s2_domainkey" {
  name                = "s2._domainkey"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "s2.domainkey.u284005.wl006.sendgrid.net"
}

resource "azurerm_dns_cname_record" "sapience_smart" {
  name                = "smart"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "whs.sendergen.com"
}

resource "azurerm_dns_cname_record" "sapience_selector1" {
  name                = "selector1._domainkey"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "selector1-sapience-net._domainkey.sapienceana.onmicrosoft.com"
}

resource "azurerm_dns_cname_record" "sapience_selector2" {
  name                = "selector2._domainkey"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "selector2-sapience-net._domainkey.sapienceana.onmicrosoft.com"
}

resource "azurerm_dns_cname_record" "sapience_autodiscover" {
  name                = "autodiscover"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "autodiscover.outlook.com"
}

resource "azurerm_dns_cname_record" "sapience_sip" {
  name                = "sip"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "sipdir.online.lync.com"
}

resource "azurerm_dns_cname_record" "sapience_lyncdiscover" {
  name                = "lyncdiscover"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "webdir.online.lync.com"
}

resource "azurerm_dns_cname_record" "sapience_enterpriseregistration" {
  name                = "enterpriseregistration"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "enterpriseregistration.windows.net"
}

resource "azurerm_dns_cname_record" "sapience_enterpriseenrollment" {
  name                = "enterpriseenrollment"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "EnterpriseEnrollment-s.manage.microsoft.com"
}

resource "azurerm_dns_cname_record" "sapience_marketing" {
  name                = "marketing"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "cloud.viewpage.co"
}

resource "azurerm_dns_cname_record" "sapience_support" {
  name                = "support"
  zone_name           = azurerm_dns_zone.sapience_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "innovizetech.freshdesk.com"
}

####################

### sapienceanalytics.com
resource "azurerm_dns_cname_record" "sapienceanalytics_email_public" {
  name                = "email"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "6869209.group9.sites.hubspot.net"
}

resource "azurerm_dns_cname_record" "sapienceanalytics_hs1_public" {
  name                = "hs1._domainkey"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "sapienceanalytics-com.hs01a.dkim.hubspotemail.net."
}

resource "azurerm_dns_cname_record" "sapienceanalytics_hs2_public" {
  name                = "hs2._domainkey"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "sapienceanalytics-com.hs01b.dkim.hubspotemail.net."
}

resource "azurerm_dns_cname_record" "sapienceanalytics_www_public" {
  name                = "www"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "sapienceanalytics_dev_public" {
  name                = "dev"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "www.dev.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "sapienceanalytics_staging_public" {
  name                = "staging"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "www.staging.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "autodiscover" {
  name                = "autodiscover"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "autodiscover.outlook.com"
}

resource "azurerm_dns_cname_record" "selector1" {
  name                = "selector1._domainkey"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "selector1-sapienceanalytics-com._domainkey.sapienceana.onmicrosoft.com"
}

resource "azurerm_dns_cname_record" "selector2" {
  name                = "selector2._domainkey"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "selector2-sapienceanalytics-com._domainkey.sapienceana.onmicrosoft.com"
}

resource "azurerm_dns_cname_record" "sip" {
  name                = "sip"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "sipdir.online.lync.com"
}

resource "azurerm_dns_cname_record" "lyncdiscover" {
  name                = "lyncdiscover"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "webdir.online.lync.com"
}

resource "azurerm_dns_cname_record" "enterpriseregistration" {
  name                = "enterpriseregistration"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "enterpriseregistration.windows.net"
}

resource "azurerm_dns_cname_record" "enterpriseenrollment" {
  name                = "enterpriseenrollment"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "enterpriseenrollment.manage.microsoft.com"
}

# OPENSENSE RECORDS
resource "azurerm_dns_cname_record" "whs" {
  name                = "smart"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "whs.sendergen.com"
}

# NGP DEV RECORDS
resource "azurerm_dns_cname_record" "login-dev-lab" {
  name                = "login.dev.lab"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "dev-piin5umt-cd-iska51tgwdkuwkl8.edge.tenants.auth0.com"
}

resource "azurerm_dns_cname_record" "help_dev" {
  name                = "help.dev"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "help.dev.lab.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "api_dev" {
  name                = "api.dev"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "api.dev.lab.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "openfaas_dev" {
  name                = "openfaas.dev"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "openfaas.dev.lab.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "portal_dev" {
  name                = "portal.dev"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.dev.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "portal_dev_lab_us" {
  name                = "portal.dev.lab.us.azure"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.dev.lab.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "portal_dev_black" {
  name                = "portal.dev.lab-black.us.azure"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.dev.lab-black.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "app_dev" {
  name                = "app.dev"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.dev.lab.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "manage_dev" {
  name                = "manage.dev"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "manage.dev.lab.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "kubernetes_dev" {
  name                = "kubernetes.dev"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "kubernetes.dev.lab.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "sisense_dev" {
  name                = "sisense.dev"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "sisense.dev.lab.us.azure.sapienceanalytics.com"
}

# resource "azurerm_dns_cname_record" "sisense_build_dev" {
#   name                = "sisense-build.dev"
#   zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
#   resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
#   ttl                 = 300
#   record              = "sisense-build.dev.lab.sapienceanalytics.com"
# }

resource "azurerm_dns_cname_record" "storybook_dev" {
  name                = "storybook.dev"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "storybook.dev.lab.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "storybook" {
  name                = "storybook"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "storybook.dev.lab.us.azure.sapienceanalytics.com"
}

# # NGP QA RECORDS
resource "azurerm_dns_cname_record" "api_qa" {
  name                = "api.qa"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "api.qa.lab.us.azure.sapienceanalytics.com"
}

/* resource "azurerm_dns_cname_record" "help_qa" {
  name                = "help.qa"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "help.qa.lab.us.azure.sapienceanalytics.com"
} */

resource "azurerm_dns_cname_record" "portal_qa" {
  name                = "portal.qa"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.qa.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "portal_qa_lab_us" {
  name                = "portal.qa.lab.us.azure"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.qa.lab.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "portal_qa_black" {
  name                = "portal.qa.lab-black.us.azure"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.qa.lab-black.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "app_qa" {
  name                = "app.qa"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.qa.lab.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "manage_qa" {
  name                = "manage.qa"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "manage.qa.lab.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "sisense_qa" {
  name                = "sisense.qa"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "sisense.qa.lab.us.azure.sapienceanalytics.com"
}

# resource "azurerm_dns_cname_record" "sisense_build_qa" {
#   name                = "sisense-build.qa"
#   zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
#   resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
#   ttl                 = 300
#   record              = "sisense-build.qa.lab.sapienceanalytics.com"
# }

# # NGP DEMO RECORDS

resource "azurerm_dns_cname_record" "api_demo" {
  name                = "api.demo"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "api.demo.lab.us.azure.sapienceanalytics.com"
}

/* resource "azurerm_dns_cname_record" "help_demo" {
  name                = "help.demo"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "help.demo.lab.us.azure.sapienceanalytics.com"
} */

resource "azurerm_dns_cname_record" "portal_demo" {
  name                = "portal.demo"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.demo.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "portal_demo_lab_us" {
  name                = "portal.demo.lab.us.azure"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.demo.lab.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "portal_demo_black" {
  name                = "portal.demo.lab-black.us.azure"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.demo.lab-black.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "app_demo" {
  name                = "app.demo"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.demo.lab.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "manage_demo" {
  name                = "manage.demo"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "manage.demo.lab.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "sisense_demo" {
  name                = "sisense.demo"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "sisense.demo.lab.us.azure.sapienceanalytics.com"
}

# NGP LOAD RECORDS
resource "azurerm_dns_cname_record" "api_load" {
  name                = "api.load"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "api.load.load.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "portal_load" {
  name                = "portal.load"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.load.load.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "sisense_load" {
  name                = "sisense.load"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "sisense.load.load.us.azure.sapienceanalytics.com"
}

# NGP PROD RECORDS
resource "azurerm_dns_cname_record" "api" {
  name                = "api"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "api.prod.prod.us.azure.sapienceanalytics.com"
}

/* resource "azurerm_dns_cname_record" "help" {
  name                = "help"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "help.prod.prod.us.azure.sapienceanalytics.com"
} */

resource "azurerm_dns_cname_record" "sisense" {
  name                = "sisense"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "sisense.prod.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "api_prod" {
  name                = "api.prod"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "api.prod.prod.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "portal_prod" {
  name                = "portal.prod"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.prod.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "portal_prod_prod_us" {
  name                = "portal.prod.prod.us.azure"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.prod.prod.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "app_prod" {
  name                = "app.prod"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.prod.prod.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "manage_prod" {
  name                = "manage.prod"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "manage.prod.prod.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "sisense_prod" {
  name                = "sisense.prod"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "sisense.prod.prod.us.azure.sapienceanalytics.com"
}

# NGP GLOBAL RECORDS
resource "azurerm_dns_cname_record" "jenkins" {
  name                = "jenkins"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "jenkins.global.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "klov" {
  name                = "klov"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "klov.global.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "sonarqube" {
  name                = "sonarqube"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "sonarqube.global.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "portal" {
  name                = "portal"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.prod.prod.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "app" {
  name                = "app"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "app.prod.prod.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "manage" {
  name                = "manage"
  zone_name           = azurerm_dns_zone.sapienceanalytics_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "manage.prod.prod.us.azure.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "spinnaker_global" {
  name                = "spinnaker"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "spinnaker.global.sapienceanalytics.com"
}

resource "azurerm_dns_cname_record" "spinnaker" {
  name                = "spinnaker.global"
  zone_name           = "${azurerm_dns_zone.sapienceanalytics_public.name}"
  resource_group_name = "${var.resource_group_name}"   # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 300
  record              = "spinnaker.global.us.azure.sapienceanalytics.com"
}

### sapiencu.com
resource "azurerm_dns_cname_record" "sapienceu_www_public" {
  name                = "www"
  zone_name           = azurerm_dns_zone.sapienceu_public.name
  resource_group_name = var.resource_group_name # for some reason, the ${azurerm_dns_zone.sapienceanalytics_public.resource_group_name} comes back as lowercase... must use ${var.resource_group_name} here
  ttl                 = 3600
  record              = "sapience.docebosaas.com"
} 