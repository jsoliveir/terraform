
output "name" {
  value = azapi_resource.communication_service.name
}

output "email_service_id" {
  description = "Email service if property [email] is set to true"
  value = var.email ? azapi_resource.email_service.0.id : null
}

output "communication_service_id" {
  value = azapi_resource.communication_service.id
}

output "email_enabled" {
  value = var.email
}

output "email_service_domain" {
  description = "Custom email domain if property [email] is set to true"
  value = var.email ? jsondecode(azapi_resource.email_service_custom_domain.0.output) : null
}

output "email_service_domain_verification_records" {
  description = "Custom email domain if property [email] is set to true"
  value = var.email ? jsondecode(azapi_resource.email_service_custom_domain.0.output).properties.verificationRecords: null
}

output "primary_connection_string" {
  value = jsondecode(azapi_resource_action.keys.output).primaryConnectionString
}
