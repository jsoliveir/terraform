resource "azurerm_public_ip" "v1" {
  resource_group_name     = var.resource_group_name
  name                    = "${var.resource_group_name}-${var.name}"
  domain_name_label       = "${var.resource_group_name}-${var.name}"
  idle_timeout_in_minutes = var.public_ip_idle_timeout_in_minutes
  sku                     = var.public_ip_sku
  location                = var.location
  tags                    = var.tags
  allocation_method       = "Static"
}

resource "azurerm_application_gateway" "v1" {
  resource_group_name = var.resource_group_name
  name                = "${var.resource_group_name}-${var.name}"
  location            = var.location
  tags                = var.tags
  enable_http2        = false

  sku {
    name     = var.sku
    tier     = var.tier
    capacity = var.capacity
  }

  dynamic "waf_configuration" {
    for_each = toset(var.sku == "WAF_v2" ? ["WAF"] : [])
    content {
      firewall_mode    = var.firewall_mode
      rule_set_version = "3.2"
      rule_set_type    = "OWASP"
      enabled          = true
    }
  }

  gateway_ip_configuration {
    subnet_id = var.subnet_id
    name      = "default"
  }

  dynamic "ssl_certificate" {
    for_each = var.certificates
    content {
      data     = ssl_certificate.value
      name     = ssl_certificate.key
      password = ""
    }

  }

  frontend_ip_configuration {
    name                          = "public"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.v1.id
  }

  dynamic "frontend_ip_configuration" {
    for_each = toset(var.private_ip_address != null ? ["private"] : [])
    content {
      name                          = "private"
      private_ip_address            = var.private_ip_address
      subnet_id                     = var.subnet_id
      private_ip_address_allocation = "Static"
    }

  }

  frontend_port {
    name = "https"
    port = 443
  }
  frontend_port {
    name = "http"
    port = 80
  }

  dynamic "probe" {
    for_each = var.listeners
    content {
      name                                      = probe.key
      protocol                                  = title(probe.value.backend_protocol)
      pick_host_name_from_backend_http_settings = probe.value.backend_host == null
      host                                      = probe.value.backend_host
      path                                      = "/healthz"
      interval                                  = 10
      timeout                                   = 10
      unhealthy_threshold                       = 3
      minimum_servers                           = 0
      match {
        status_code = ["200-404"]
        body        = ""
      }
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.listeners
    content {
      ip_addresses = [
        for ip in backend_address_pool.value.backend_pool : ip
        if length(regexall("[0-9]+.[0-9]+.[0-9]+", ip)) > 0
      ]
      fqdns = [
        for ip in backend_address_pool.value.backend_pool : ip
        if length(regexall("[0-9]+.[0-9]+.[0-9]+", ip)) == 0
      ]
      name = backend_address_pool.key
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.listeners
    content {
      cookie_based_affinity               = "Disabled"
      name                                = backend_http_settings.key
      probe_name                          = backend_http_settings.key
      port                                = lower(backend_http_settings.value.backend_protocol) == "http" ? 80 : 443
      protocol                            = title(backend_http_settings.value.backend_protocol)
      pick_host_name_from_backend_address = backend_http_settings.value.backend_host == null
      host_name                           = backend_http_settings.value.backend_host
      path                                = "/"
      request_timeout                     = 500
    }
  }

  dynamic "http_listener" {
    for_each = var.listeners
    content {
      frontend_ip_configuration_name = http_listener.value.public ? "public" : "private"
      ssl_certificate_name           = http_listener.value.certificate
      name                           = http_listener.key
      host_name                      = http_listener.key
      protocol                       = "Https"
      frontend_port_name             = "https"
      require_sni                    = false
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.listeners
    content {
      rule_type = "Basic"      
      backend_http_settings_name = lower(request_routing_rule.key)
      name                       = request_routing_rule.key
      http_listener_name         = request_routing_rule.key
      backend_address_pool_name  = request_routing_rule.key
      priority = (
        var.tier != "Standard"
        ? (index(keys(var.listeners), request_routing_rule.key) + 1) + 100
        : null
      )
    }
  }

  dynamic "http_listener" {
    for_each = var.listeners
    content {
      frontend_ip_configuration_name = http_listener.value.public ? "public" : "private"
      ssl_certificate_name           = http_listener.value.certificate
      name                           = "${http_listener.key}_redirect"
      host_name                      = http_listener.key
      protocol                       = "Http"
      frontend_port_name             = "http"
      require_sni                    = false
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.listeners
    content {
      rule_type = "Basic"      
      http_listener_name          = "${request_routing_rule.key}_redirect"
      redirect_configuration_name = "${request_routing_rule.key}_redirect"
      name                        = "${request_routing_rule.key}_redirect"
      priority = (
        var.tier != "Standard"
        ? (index(keys(var.listeners), request_routing_rule.key) + 1) + 1000
        : null
      )
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.listeners
    content {
      name                 = "${redirect_configuration.key}_redirect"
      target_listener_name = redirect_configuration.key
      redirect_type        = "Permanent"
      include_path         = true
      include_query_string = true
    }
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20150501"
  }

  lifecycle {
    create_before_destroy = true
  }
}
