module "private_dns_zone" {
  for_each            = local.config.azure.privateDnsZones
  source              = "../../../../modules/terraform/azure/PrivateDnsZone/v1"
  resource_group_name = module.resource_group.name
  tags                = local.tags
  name                = each.key

  dns_a_records = [
    for record in flatten(each.value) : {
      records = record.values
      ttl     = record.ttl
      name    = record.name
  } if record.type == "A"]

  dns_cname_records = [
    for record in flatten(each.value) : {
      record = record.value
      ttl    = record.ttl
      name   = record.name
  } if record.type == "CNAME"]
}
