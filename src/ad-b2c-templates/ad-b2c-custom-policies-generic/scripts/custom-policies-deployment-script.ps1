Write-Host " Function started"

[Cmdletbinding()]
Param(
    [Parameter(Mandatory = $true)][string]$ClientID,
    [Parameter(Mandatory = $true)][string]$ClientSecret,
    [Parameter(Mandatory = $true)][string]$TenantId,
    [Parameter(Mandatory = $true)][string]$PolicyId,
    [Parameter(Mandatory = $true)][string]$PathToFile,
    [Parameter(Mandatory = $true)][string]$ProxyIdentityExperienceFrameworkAppId,
    [Parameter(Mandatory = $true)][string]$IdentityExperienceFrameworkAppId,
    [Parameter(Mandatory = $false)][string]$StorageAccountPath,
    [Parameter(Mandatory = $false)][string]$FacebookClientId
)
Write-Host " Function started 2"
Function ReplacePlaceholderWithValueInFile
{
    param( 
        [string]$placeholder,
        [string]$actualValue)

    $customPolicyFileContent = Get-Content -Path $PathToFile -Raw
    $customPolicyFileContent -replace $placeholder, $actualValue | Set-Content -Encoding UTF8 -Path $PathToFile
}

Write-Host " Function started 3"
ReplacePlaceholderWithValueInFile -placeholder "##TENANT_ID##" -actualValue $TenantId
ReplacePlaceholderWithValueInFile -placeholder "##ProxyIdentityExperienceFrameworkAppId##" -actualValue $ProxyIdentityExperienceFrameworkAppId
ReplacePlaceholderWithValueInFile -placeholder "##IdentityExperienceFrameworkAppId##" -actualValue $IdentityExperienceFrameworkAppId
ReplacePlaceholderWithValueInFile -placeholder "##STORAGE_ACCOUNT_PATH##" -actualValue $StorageAccountPath
ReplacePlaceholderWithValueInFile -placeholder "##FACEBOOK_CLIENT_ID##" -actualValue $FacebookClientId

ReplacePlaceholderWithValueInFile -placeholder "##AD_B2C_TENANT_ID##" -actualValue $TenantId
ReplacePlaceholderWithValueInFile -placeholder "##PROXY_IDENTITY_EXPERIENCE_FRAMEWORK_APP_ID##" -actualValue $ProxyIdentityExperienceFrameworkAppId
ReplacePlaceholderWithValueInFile -placeholder "##IDENTITY_EXPERIENCE_FRAMEWORK_APP_ID##" -actualValue $IdentityExperienceFrameworkAppId
ReplacePlaceholderWithValueInFile -placeholder "##AD_B2C_BRANDING_ASSETS_STORAGE_ACCOUNT_CONN_STR##" -actualValue $StorageAccountPath
ReplacePlaceholderWithValueInFile -placeholder "##AD_B2C_MANAGEMENT_APP_CLIENT_ID##" -actualValue $ClientID
ReplacePlaceholderWithValueInFile -placeholder "##AD_B2C_MANAGEMENT_APP_CLIENT_SECRET##" -actualValue $ClientSecret

Write-Host "Tenant ID" $TenantId "Tenant ID using secret."

$TenantId = "24c6d5a3-5eb7-453c-b8a5-72495d9f135e"
$ClientID = "15e801c0-e1dd-4569-9621-950ecb36bfef"
$ClientSecret = ".FB2W8cvs1NHlPI~ian3-uEZm17I_a8eu."

Write-Host "Tenant ID" $TenantId "Tenant ID using hardcoded."
try {
    $body = @{grant_type = "client_credentials"; scope = "https://graph.microsoft.com/.default"; client_id = $ClientID; client_secret = $ClientSecret }

    $response = Invoke-RestMethod -Uri https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token -Method Post -Body $body
    $token = $response.access_token

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", 'application/xml')
    $headers.Add("Authorization", 'Bearer ' + $token)

    $graphuri = 'https://graph.microsoft.com/beta/trustframework/policies/' + $PolicyId + '/$value'
    $policycontent = Get-Content $PathToFile
    $response = Invoke-RestMethod -Uri $graphuri -Method Put -Body $policycontent -Headers $headers

    Write-Host "Policy" $PolicyId "uploaded successfully."
}
catch {
    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__

    $_

    $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
    $streamReader.BaseStream.Position = 0
    $streamReader.DiscardBufferedData()
    $errResp = $streamReader.ReadToEnd()
    $streamReader.Close()

    $ErrResp

    exit 1
}

exit 0
