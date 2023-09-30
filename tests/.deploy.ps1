#!/usr/bin/env pwsh
param ( 
  $ErrorActionPreference="Stop"
)

try {
  $Session = az account show 2> $null | ConvertFrom-Json
}
finally {
  if (!$Session) {
    if (!$env:ARM_CLIENT_ID) {
      az login
    } 
    else {
      az login --service-principal `
        --password $env:ARM_CLIENT_SECRET `
        --username $env:ARM_CLIENT_ID `
        --tenant $env:ARM_TENANT_ID 
    }
  }
  if ($LASTEXITCODE) {
    Write-Error "az login has failed"
    exit 1
  }
}

if ($Confirm) 
{ $Parameters += "-auto-approve" }

terraform -chdir="$PSScriptRoot" init -migrate-state

terraform -chdir="$PSScriptRoot" apply -refresh=false $Parameters

if ($LASTEXITCODE) {
  Write-Error "Deployment has failed"
  exit 1;
}
