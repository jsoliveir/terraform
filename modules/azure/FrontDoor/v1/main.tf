data "azurerm_dns_zone" "v1" {
  resource_group_name = var.dns_zone_resource_group
  name                = var.dns_zone_name
}

resource "azurerm_cdn_frontdoor_profile" "v1" {
  name                = "${var.resource_group_name}-${var.name}"
  resource_group_name = var.resource_group_name
  tags                = var.tags
  sku_name            = var.sku
}

resource "azurerm_cdn_frontdoor_custom_domain" "v1" {
  for_each                 = var.endpoints
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.v1.id
  host_name                = each.value
  name                     = each.key
  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}


resource "azurerm_cdn_frontdoor_endpoint" "v1" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.v1.id
  for_each                 = var.endpoints
  name                     = each.key
}

resource "azurerm_cdn_frontdoor_origin_group" "v1" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.v1.id
  for_each                 = var.origins
  name                     = each.key

  health_probe {
    interval_in_seconds = 10
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  load_balancing {
    sample_size                        = 16
    additional_latency_in_milliseconds = 0
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "v1" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.v1[each.key].id
  for_each                       = var.origins
  host_name                      = each.value
  origin_host_header             = each.value
  name                           = each.key
  enabled                        = true
  certificate_name_check_enabled = false
  http_port                      = 80
  https_port                     = 443
  priority                       = 1
  weight                         = 1
}

resource "azurerm_cdn_frontdoor_rule_set" "v1" {
  for_each                 = var.rulesets
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.v1.id
  name                     = each.key
}

resource "azurerm_cdn_frontdoor_rule" "v1" {
  for_each                  = var.rulesets
  name                      = each.key
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.v1[each.key].id
  order                     = index(keys(var.rulesets), each.key) * 100
  actions {
    dynamic "request_header_action" {
      for_each = toset(each.value.modifyRequestHeader != null ? ["modifyRequestHeader"] : [])
      content {
        header_action = each.value.modifyRequestHeader.headerAction
        header_name   = each.value.modifyRequestHeader.headerName
        value         = each.value.modifyRequestHeader.value
      }
    }

    dynamic "response_header_action" {
      for_each = toset(each.value.modifyResponseHeader != null ? ["modifyResponseHeader"] : [])
      content {
        header_action = each.value.modifyResponseHeader.headerAction
        header_name   = each.value.modifyResponseHeader.headerName
        value         = each.value.modifyResponseHeader.value
      }
    }

    dynamic "route_configuration_override_action" {
      for_each = toset(each.value.routeConfigurationOverride != null ? ["routeConfigurationOverride"] : [])
      content {
        cache_behavior                = each.value.routeConfigurationOverride.cacheBehavior
        cache_duration                = each.value.routeConfigurationOverride.cacheDuration
        compression_enabled           = each.value.routeConfigurationOverride.compressionEnabled
        query_string_caching_behavior = each.value.routeConfigurationOverride.queryStringCachingBehavior
      }
    }
    
    dynamic "url_rewrite_action" {
      for_each = toset(each.value.urlRewrite != null ? ["urlRewrite"] : [])
      content {
        source_pattern          = each.value.urlRewrite.source
        destination             = each.value.urlRewrite.destination
        preserve_unmatched_path = each.value.urlRewrite.preserveUnmatchedPath
      }
    }
  }
}

resource "azurerm_cdn_frontdoor_route" "v1" {
  for_each                        = var.routes
  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.v1[each.value.endpoint].id]
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.v1[each.value.origin].id
  cdn_frontdoor_rule_set_ids = [
    for ruleset in each.value.rulesets :
    azurerm_cdn_frontdoor_rule_set.v1[ruleset].id
  ]
  cdn_frontdoor_endpoint_id = azurerm_cdn_frontdoor_endpoint.v1[each.value.endpoint].id
  cdn_frontdoor_origin_ids  = [azurerm_cdn_frontdoor_origin.v1[each.value.origin].id]
  patterns_to_match         = ["/*"]
  cdn_frontdoor_origin_path = "/"
  supported_protocols       = ["Http", "Https"]
  forwarding_protocol       = "HttpsOnly"
  name                      = each.key
  link_to_default_domain    = false
  enabled                   = true
  https_redirect_enabled    = true

  dynamic "cache" {
    for_each = toset(each.value.cache ? ["enabled"] : [])
    content {
      compression_enabled = true
      content_types_to_compress = [
        "application/eot",
        "application/font",
        "application/font-sfnt",
        "application/javascript",
        "text/plain",
        "application/json",
        "application/opentype",
        "application/otf",
        "application/pkcs7-mime",
        "application/truetype",
        "application/ttf",
        "application/vnd.ms-fontobject",
        "application/xhtml+xml",
        "application/xml",
        "application/xml+rss",
        "application/x-font-opentype",
        "application/x-font-truetype",
        "application/x-font-ttf",
        "application/x-httpd-cgi",
        "application/x-javascript",
        "application/x-mpegurl",
        "application/x-opentype",
        "application/x-otf",
        "application/x-perl",
        "application/x-ttf",
        "font/eot",
        "font/ttf",
        "font/otf",
        "font/opentype",
        "image/svg+xml",
        "text/css",
        "text/csv",
        "text/html",
        "application/javascript",
        "application/xml",
        "text/javascript",
        "text/js",
        "text/plain",
        "text/richtext",
        "text/tab-separated-values",
        "text/xml",
        "text/x-script",
        "text/x-component",
        "text/x-java-source",
        "text/html",
        "text/css",
      ]
    }
  }
  lifecycle {
    replace_triggered_by = [
      azurerm_cdn_frontdoor_custom_domain.v1,
      azurerm_cdn_frontdoor_rule_set.v1,
    ]
  }
}

resource "azurerm_dns_txt_record" "_dnsauth" {
  for_each            = var.endpoints
  resource_group_name = var.dns_zone_resource_group
  name                = "_dnsauth.${replace(each.value, ".${var.dns_zone_name}", "")}"
  zone_name           = var.dns_zone_name
  tags                = var.tags
  ttl                 = 10
  record {
    value = azurerm_cdn_frontdoor_custom_domain.v1[each.key].validation_token
  }
}
