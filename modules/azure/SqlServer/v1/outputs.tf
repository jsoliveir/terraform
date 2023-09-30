output "servers" {
  value = azurerm_mssql_server.v1
}

output "admin_user" {
  value = (
    length(keys(var.servers)) > 0 
    ? [for _,sql in azurerm_mssql_server.v1: sql.administrator_login][0]
    : null
    )
}

output "admin_pass" {
  value = (
    length(keys(var.servers)) > 0 
    ? random_password.v1.0.result
    : null
  )
}
