data "azurerm_subscription" "current" {}

resource "azapi_resource" "email_service" {
  count     = var.email ? 1 : 0
  type      = "Microsoft.Communication/emailServices@2023-03-01-preview"
  parent_id = "${data.azurerm_subscription.current.id}/resourceGroups/${var.resource_group_name}"
  name      = "${var.resource_group_name}-${var.name}"
  location  = "global"
  tags      = var.tags
  body = jsonencode({
    properties = {
      dataLocation = var.data_location
    }
  })
}

resource "azapi_resource" "email_service_custom_domain" {
  count     = var.email ? 1 : 0
  type      = "Microsoft.Communication/emailServices/domains@2023-03-01-preview"
  name      = regex(".*/(.*)$", var.public_dns_zone_id)[0]
  parent_id = azapi_resource.email_service.0.id
  depends_on = [
    azapi_resource.email_service_custom_domain
  ]
  tags                   = var.tags
  location               = "global"
  response_export_values = ["*"]
  body = jsonencode({
    properties = {
      domainManagement = "CustomerManaged"
    }
  })
}

resource "azapi_resource" "email_sender" {
  for_each  = var.email ? var.email_senders : {}
  type      = "Microsoft.Communication/emailServices/domains/senderUsernames@2023-03-31"
  parent_id = azapi_resource.email_service_custom_domain.0.id
  name      = replace(each.value, "/@.*/", "")
  body = jsonencode({
    properties = {
      username    = replace(each.value, "/@.*/", "")
      displayName = each.key
    }
  })
}


# Domain validation records

data "azapi_resource" "txt" {
  type                   = "Microsoft.Network/dnsZones/TXT@2018-05-01"
  parent_id              = var.public_dns_zone_id
  response_export_values = ["*"]
  name                   = "@"
}

locals {
  txt_records = jsondecode(data.azapi_resource.txt.output).properties.TXTRecords
  txt_records_values = !var.email ? local.txt_records : concat(
    [
      for record in local.txt_records : record
      if !startswith(record.value[0], jsondecode(azapi_resource.email_service_custom_domain.0.output).properties.verificationRecords.Domain.value)
    ],
    [{
      value = [jsondecode(azapi_resource.email_service_custom_domain.0.output).properties.verificationRecords.Domain.value]
    }]
  )
}

resource "azapi_update_resource" "TXT_records" {
  count       = var.email ? 1 : 0
  type        = "Microsoft.Network/dnsZones/TXT@2018-05-01"
  resource_id = data.azapi_resource.txt.id
  body = jsonencode({
    properties = {
      TXTRecords = local.txt_records_values
    }
  })
}

resource "azapi_resource" "DKIM_record" {
  count     = var.email ? 1 : 0
  type      = "Microsoft.Network/dnsZones/CNAME@2018-05-01"
  parent_id = var.public_dns_zone_id
  name      = jsondecode(azapi_resource.email_service_custom_domain.0.output).properties.verificationRecords.DKIM.name
  body = jsonencode({
    properties = {
      TTL = 3600
      CNAMERecord = {
        cname = jsondecode(azapi_resource.email_service_custom_domain.0.output).properties.verificationRecords.DKIM.value
      }
    }
  })
}

resource "azapi_resource" "DKIM2_record" {
  count     = var.email ? 1 : 0
  type      = "Microsoft.Network/dnsZones/CNAME@2018-05-01"
  parent_id = var.public_dns_zone_id
  name      = jsondecode(azapi_resource.email_service_custom_domain.0.output).properties.verificationRecords.DKIM2.name
  body = jsonencode({
    properties = {
      TTL = 3600
      CNAMERecord = {
        cname = jsondecode(azapi_resource.email_service_custom_domain.0.output).properties.verificationRecords.DKIM2.value
      }
    }
  })
}

# Domain validation actions

resource "azapi_resource_action" "DOMAIN_validation" {
  count       = var.email ? 1 : 0
  type        = "Microsoft.Communication/emailServices/domains@2023-03-31"
  resource_id = azapi_resource.email_service_custom_domain.0.id
  action      = "initiateVerification"
  body = jsonencode({
    verificationType = "Domain"
  })
}

resource "azapi_resource_action" "SPF_validation" {
  count       = var.email ? 1 : 0
  type        = "Microsoft.Communication/emailServices/domains@2023-03-31"
  resource_id = azapi_resource.email_service_custom_domain.0.id
  action      = "initiateVerification"
  body = jsonencode({
    verificationType = "SPF"
  })
}

resource "azapi_resource_action" "DKIM_validation" {
  count       = var.email ? 1 : 0
  type        = "Microsoft.Communication/emailServices/domains@2023-03-31"
  resource_id = azapi_resource.email_service_custom_domain.0.id
  action      = "initiateVerification"
  body = jsonencode({
    verificationType = "DKIM"
  })
}

resource "azapi_resource_action" "DKIM2_validation" {
  count       = var.email ? 1 : 0
  type        = "Microsoft.Communication/emailServices/domains@2023-03-31"
  resource_id = azapi_resource.email_service_custom_domain.0.id
  action      = "initiateVerification"
  body = jsonencode({
    verificationType = "DKIM2"
  })
}

# Link custom domain to the existing communication services

resource "time_sleep" "wait_for_domain_validation" {
  count           = var.email ? 1 : 0
  create_duration = "60s"
  depends_on = [
    azapi_resource_action.DOMAIN_validation.0,
    azapi_resource_action.DKIM2_validation.0,
    azapi_resource_action.DKIM_validation.0,
    azapi_resource_action.SPF_validation.0,
  ]
  lifecycle {
    replace_triggered_by = [
      azapi_resource.email_service_custom_domain
    ]
  }
}

resource "azapi_resource" "communication_service" {
  parent_id = "${data.azurerm_subscription.current.id}/resourceGroups/${var.resource_group_name}"
  type      = "Microsoft.Communication/communicationServices@2023-03-01-preview"
  name      = "${var.resource_group_name}-${var.name}"
  location  = "global"
  depends_on = [
    azapi_resource.email_service_custom_domain,
    time_sleep.wait_for_domain_validation
  ]
  body = jsonencode({
    properties = {
      dataLocation = var.data_location
    }
  })
}

resource "azapi_update_resource" "communication_service" {
  type        = "Microsoft.Communication/communicationServices@2023-03-01-preview"
  resource_id = azapi_resource.communication_service.id
  depends_on = [
    time_sleep.wait_for_domain_validation
  ]
  body = jsonencode({
    properties = {
      linkedDomains = [
        for d in azapi_resource.email_service_custom_domain : d.id
      ]
    }
  })
  lifecycle {
    create_before_destroy = true
    replace_triggered_by = [
      azapi_resource.email_service_custom_domain,
      time_sleep.wait_for_domain_validation,
      azapi_resource.communication_service
    ]
  }
}

resource "azapi_resource_action" "keys" {
  type                   = "Microsoft.Communication/communicationServices@2023-03-31"
  resource_id            = azapi_resource.communication_service.id
  action                 = "listKeys"
  response_export_values = ["*"]

}
