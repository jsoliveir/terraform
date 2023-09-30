. $PSScriptRoot\API.ps1

New-PritunlSession -Username pritunl

New-PritunlOrganization -Name "habitushealth.net"

New-PritunlServer -Name "DEVELOPMENT"

New-PritunlUser -Name "jose"

Clear-PritunlServerRoutes

New-PritunlServerIpRoute "10.0.0.0/8"

New-PritunlServerIpRoute "168.63.129.16"