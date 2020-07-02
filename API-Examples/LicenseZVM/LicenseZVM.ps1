#Requires -PSEdition Core

<#
.SYNOPSIS
   This script will apply a specified license key to a Zerto Virtual Manager (ZVM).
.DESCRIPTION
   This script requires some variables to be set for the License Key, ZVM Hostname/IP address, ZVM TCP Port (if not the default), as well as authentication info.
.VERSION
   Applicable versions of Zerto Products script has been tested on.  Unless specified, all scripts in repository will be 5.0u3 and later.
.LEGAL
   Legal Disclaimer:

----------------------
This script is an example script and is not supported under any Zerto support program or service.
The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without
limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability
to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages.  The entire risk arising out of the use or
performance of the sample scripts and documentation remains with you.
----------------------
#>

###################################################################################################################
#Any section containing a "GOES HERE" should be replaced and populated with your site information for the script to work.#
###################################################################################################################
# Configure the variables below
###################################################################################################################
$LicenseKey = "GOES HERE"  # Enter your Zerto License Key here
$ZertoServer = "GOES HERE"  # Enter the Hostname/IP of the Zerto Virtual Manager (ZVM) to connect to
$ZertoPort = "9669" # Only Update if using a Nonstandard port.
$ZertoUserName = "GOES HERE"    # Enter the ZVM username
$ZertoPassword = "GOES HERE" | ConvertTo-SecureString -AsPlainText  # Enter the ZVM Password
$ZertoCredentials = [PSCredential]::New($ZertoUserName, $ZertoPassword)

#--------------------------------------------------------------------------------------------------------------#
# Nothing to configure below this line
#--------------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------------------#
# Building Zerto API string and invoking API
#--------------------------------------------------------------------------------------------------------------#
$baseURL = "https://" + $ZertoServer + ":" + $ZertoPort + "/v1/"
# Authenticating with Zerto APIs
$ZertoHeaders = @{
    Accept = 'application/json'
}
$RestMethodParameters = @{
    Headers                 = $ZertoHeaders
    ContentType             = 'application/json'
    ResponseHeadersVariable = 'ReturnHeaders'
    StatusCodeVariable      = 'ReturnStatusCode'
    SkipCertificateCheck    = $true
}
$URI = $baseURL + 'session/add'
Try {
    $null = Invoke-RestMethod @RestMethodParameters -Method "POST" -URI $URI -Credential $ZertoCredentials
} Catch {
    Write-Host $_.Exception.ToString()
    $error[0] | Format-List -Force
}

#--------------------------------------------------------------------------------------------------------------#
# Apply a New License or Update an Existing License
#--------------------------------------------------------------------------------------------------------------#
$ZertoHeaders = @{
    Accept            = 'application/json'
    "x-zerto-session" = $ReturnHeaders.'x-zerto-session'[0]
}
$RestMethodParameters = @{
    Headers                 = $ZertoHeaders
    ContentType             = 'application/json'
    ResponseHeadersVariable = 'ReturnHeaders'
    StatusCodeVariable      = 'ReturnStatusCode'
    SkipCertificateCheck    = $true
}
$URI = $baseURL + 'license'
$body = @{LicenseKey = $LicenseKey }
Try {
    $null = Invoke-RestMethod @RestMethodParameters -Method "PUT" -URI $URI -Body ($body | ConvertTo-Json)
} Catch {
    Write-Host $_.Exception.ToString()
    $error[0] | Format-List -Force
}