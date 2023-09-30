variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "name" {
  type = string
}

variable "sku" {
  default = "Standard_AzureFrontDoor"
}

variable "dns_zone_name" {
  type = string
}

variable "dns_zone_resource_group" {
  type = string
}

variable "endpoints" {
  type = map(string)
}

variable "origins" {
  type = map(string)
}

variable "routes" {
  type = map(object({
    rulesets = list(string)
    endpoint = string
    origin   = string
    cache    = bool
  }))
}

variable "rulesets" {
  type = map(object({
    modifyResponseHeader = optional(object({
      headerAction = string
      headerName   = string
      value        = string
    }), null)

    modifyRequestHeader = optional(object({
      headerAction = string
      headerName   = string
      value        = string
    }), null)

    routeConfigurationOverride = optional(object({
      queryStringCachingBehavior = optional(string, "UseQueryString")
      cacheBehavior              = optional(string, "OverrideAlways")
      cacheDuration              = optional(string, "1.00:00:00")
      compressionEnabled         = optional(bool, true)
    }), null)

    urlRewrite = optional(object({
      preserveUnmatchedPath = bool
      destination           = string
      source                = string
    }), null)

  }))
}
