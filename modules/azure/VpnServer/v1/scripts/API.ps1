
$env:API_BASE_URL="https://vpn.habitushealth.net"

Function New-PritunlSession {
  param(
    [Parameter(Mandatory)] [string] $Username,
    [Parameter(Mandatory)] [SecureString] $Password
  )
  $UnsecurePassword = ConvertFrom-SecureString -SecureString $Password -AsPlainText
  Invoke-RestMethod -Uri "$env:API_BASE_URL/auth/session" `
    -SkipCertificateCheck `
    -Method "POST" `
    -SessionVariable global:PRITUNL_SESSION `
    -ContentType "application/json" `
    -Body "{`"username`":`"$Username`",`"password`":`"$UnsecurePassword`"}" 
}

Function Get-PritunlHeaders {
  param(
    [Parameter()] $Session = $global:PRITUNL_SESSION
  )
  $CSRF = Invoke-RestMethod -Uri "$env:API_BASE_URL/state" `
    -SkipCertificateCheck `
    -WebSession $Session 
  return @{
    "csrf-token"= $CSRF.csrf_token
    "accept"="application/json, text/javascript, */*; q=0.01"
    "content-type"="application/json"
  } 
}

Function Set-PritunlSettings {
  param(
    [Parameter()] $PublicAddress = "vpn.habitushealth.net",
    [Parameter()] $Session = $global:PRITUNL_SESSION,
    [Parameter()] $Headers = (Get-PritunlHeaders), 
    [Parameter()] $ServerPort = "443"
  )
  Invoke-WebRequest -UseBasicParsing -Uri "$env:API_BASE_URL/settings" `
    -SkipCertificateCheck `
    -WebSession $Session `
    -Headers $Headers `
    -Method "PUT" `
    -Body "{
      `"username`":`"pritunl`",
      `"password`": null,
      `"public_address`":`"$PublicAddress`",
      `"server_port`": $ServerPort,
      }"
}

Function New-PritunlOrganization {
  param(
    [Parameter()] $Session = $global:PRITUNL_SESSION,
    [Parameter()] $Headers = (Get-PritunlHeaders),
    [Parameter(Mandatory)] $Name
  )
  return (Invoke-RestMethod -Uri "$env:API_BASE_URL/organization" `
    -SkipCertificateCheck `
    -Method "POST" `
    -WebSession $Session `
    -Headers $Headers `
    -Body "{
      `"id`":null,
      `"name`":`"$Name`",
      `"user_count`":null
    }")
}

Function New-PritunlServer {
  param(
    [Parameter(Mandatory)] $Name,
    [Parameter()] $OrganizationId=(Get-PritunlOrganizations)[0].id,
    [Parameter()] $Session = $global:PRITUNL_SESSION,
    [Parameter()] $Headers = (Get-PritunlHeaders),
    [Parameter()] $Network = "192.168.240.0/24",
    [Parameter()] $DnsServer = "168.63.129.16",
    [Parameter()] $DnsServerDomains = "int.habitushealth.net, windows.net"
    
  )
  $Server = Invoke-RestMethod -Uri "$env:API_BASE_URL/server" `
    -SkipCertificateCheck `
    -Method "POST" `
    -WebSession $Session `
    -Headers $Headers `
    -Body "{
      `"name`":`"$Name`",
      `"network`":`"$Network`",
      `"port`":1194,
      `"protocol`":`"udp`",
      `"dh_param_bits`":2048,
      `"ipv6_firewall`":true,
      `"dns_servers`":[`"$DnsServer`"],
      `"cipher`":`"aes128`",
      `"hash`":`"sha1`",
      `"inter_client`":true,
      `"restrict_routes`":false,
      `"vxlan`":true,
      `"ipv6`":false,
      `"network_mode`":`"tunnel`",
      `"wg`":false,
      `"multi_device`":true,
      `"search_domain`":`"$DnsServerDomains`",
      `"otp_auth`":false,
      `"block_outside_dns`":false,
      `"replica_count`":1,
      `"dns_mapping`":false,
      `"debug`":false
    }"

    Invoke-RestMethod -UseBasicParsing -Uri "$env:API_BASE_URL/server/$($Server.id)/organization/$OrganizationId" `
      -SkipCertificateCheck `
      -Method "PUT" `
      -WebSession $Session `
      -Headers $Headers `
      | Select-Object server, name
}

Function Get-PritunlOrganizations {
  param(
    [Parameter()] $Session = $global:PRITUNL_SESSION,
    [Parameter()] $Headers = (Get-PritunlHeaders) 
  )
  return (Invoke-RestMethod -Uri "$env:API_BASE_URL/organization?page=0" `
    -SkipCertificateCheck `
    -WebSession $Session `
    -Headers $Headers).organizations
}

Function Remove-PritunlOrganizations {
  param(
    [Parameter()] $OrganizationId=(Get-PritunlOrganizations)[0].id,
    [Parameter()] $Session = $global:PRITUNL_SESSION,
    [Parameter()] $Headers = (Get-PritunlHeaders) 
  )
  Invoke-RestMethod  -Uri "$env:API_BASE_URL/organization/$OrganizationId" `
    -SkipCertificateCheck `
    -WebSession $Session `
    -Headers $Headers `
    -Method "DELETE" `
    -Verbose
}


Function Get-PritunlUsers {
  param(
    [Parameter()] $OrganizationId=(Get-PritunlOrganizations)[0].id,
    [Parameter()] $Session = $global:PRITUNL_SESSION,
    [Parameter()] $Headers = (Get-PritunlHeaders) 
  )
  return (Invoke-RestMethod -Uri "$env:API_BASE_URL/user/$OrganizationId" `
    -SkipCertificateCheck `
    -WebSession $Session `
    -Headers $Headers `
    | ConvertTo-Json `
    | ConvertFrom-Json
  )
}

Function New-PritunlUser {
  param(
    [Parameter()] $OrganizationId=(Get-PritunlOrganizations)[0].id,
    [Parameter()] $Session = $global:PRITUNL_SESSION,
    [Parameter()] $Headers = (Get-PritunlHeaders),
    [Parameter(Mandatory)] $Name,
    [Parameter()] $Email
  )
  return (Invoke-RestMethod -Uri "$env:API_BASE_URL/user/$($OrganizationId)" `
    -SkipCertificateCheck `
    -WebSession $Session `
    -Headers $Headers `
    -Method "POST" `
    -Body "{
      `"organization`":`"$OrganizationId`",
      `"name`":`"$Name`",
      `"email`":`"$Email`",
      `"groups`":[]
    }")
}
Function Remove-PritunlUser {
  param(
    [Parameter()] $OrganizationId=(Get-PritunlOrganizations)[0].id,
    [Parameter()] $Session = $global:PRITUNL_SESSION,
    [Parameter()] $Headers = (Get-PritunlHeaders),
    [Parameter(Mandatory)] $UserId
  )
    Invoke-WebRequest -Uri "$env:API_BASE_URL/user/$OrganizationId/$UserId" `
      -SkipCertificateCheck `
      -WebSession $Session `
      -Headers $Headers `
      -Method "DELETE" `
      | Out-Null
}


Function Get-PritunlLinks {
  param(
    [Parameter()] $OrganizationId=(Get-PritunlOrganizations)[0].id,
    [Parameter()] $Session = $global:PRITUNL_SESSION,
    [Parameter()] $Headers = (Get-PritunlHeaders),
    [Parameter(Mandatory)] $UserId
  )

Invoke-WebRequest -UseBasicParsing -Uri "$env:API_BASE_URL/key/$OrganizationId/$UserId" `
  -WebSession $session `
  -Headers $Headers
}


Function Get-PritunlServers {
  param(
    [Parameter()] $Session = $global:PRITUNL_SESSION,
    [Parameter()] $Headers = (Get-PritunlHeaders)
  )
  return (Invoke-RestMethod -Uri "$env:API_BASE_URL/server?page=0" `
    -WebSession $Session `
    -Headers $Headers
  ).servers

}
Function New-PritunlServerIpRoute {
  param(
    [Parameter(Mandatory)] $Route,
    [Parameter()] $ServerId=(Get-PritunlServers)[0].id,
    [Parameter()] $Session = $global:PRITUNL_SESSION,
    [Parameter()] $Headers = (Get-PritunlHeaders)
  )
  Invoke-RestMethod -Uri "$env:API_BASE_URL/server/$ServerId/route" `
    -WebSession $session `
    -Headers $Headers `
    -Method "POST" `
    -Body "{`"id`":null,`"server`":`"$ServerId`",`"network`":`"$Route`",`"comment`":`"`",`"metric`":null,`"virtual_network`":null,`"wg_network`":null,`"network_link`":null,`"server_link`":null,`"nat`":true,`"nat_interface`":`"`",`"nat_netmap`":`"`",`"net_gateway`":false,`"advertise`":false,`"vpc_region`":null,`"vpc_id`":null}"
}


Function Get-PritunlServerRoutes {
  param(
    [Parameter()] $ServerId=(Get-PritunlServers)[0].id,
    [Parameter()] $Session = $global:PRITUNL_SESSION,
    [Parameter()] $Headers = (Get-PritunlHeaders)
  )

  return (Invoke-RestMethod -Uri "$env:API_BASE_URL/server/$ServerId/route" `
    -WebSession $session `
    -Headers $Headers
  )
}

Function Clear-PritunlServerRoutes {
  param(
    [Parameter()] $ServerId=(Get-PritunlServers)[0].id,
    [Parameter()] $Session = $global:PRITUNL_SESSION,
    [Parameter()] $Headers = (Get-PritunlHeaders)
  )

    foreach($route in (Get-PritunlServerRoutes)) {
      Invoke-RestMethod -Method Delete -Uri "$env:API_BASE_URL/server/$ServerId/route/$($route.id)" `
        -WebSession $session `
        -Headers $Headers
    }
}