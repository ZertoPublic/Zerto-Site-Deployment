#Requires -PSEdition Core

<#
.SYNOPSIS
   This script will pair Source and Target Zerto Virtual Managers (ZVMs).
.DESCRIPTION
   This script requires some variables to be set for the Source and Target ZVM Hostname/IP address, Source and Target ZVM TCP Port (if not the default), as well as authentication info.
.VERSION
   Applicable versions of Zerto Products script has been tested on:
   Version 7.5 and above
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
$ZertoServerSource = "GOES HERE"  # Enter the Hostname/IP of the Source ZVM to connect to
$ZertoServerDest = "GOES HERE"  # Enter the Hostname/IP of the Target ZVM to connect to
$ZertoPortSource = "9669" # Only Update if using a Nonstandard port.
$ZertoPortDest = "9669" # Only Update if using a Nonstandard port.
$ZertoPairingPort = "9071" # Only Update if using a Nonstandard port.
$ZertoUserName = "GOES HERE" # Enter the ZVM username
$ZertoPassword = "GOES HERE" | ConvertTo-SecureString -AsPlainText  # Enter the ZVM Password
$ZertoCredentials = [PSCredential]::New($ZertoUserName, $ZertoPassword)

#--------------------------------------------------------------------------------------------------------------#
# Nothing to configure below this line
#--------------------------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------------------#
# Building Zerto API string and invoking API on Destination Site ZVM
#--------------------------------------------------------------------------------------------------------------#
$baseURL = "https://" + $ZertoServerDest + ":" + $ZertoPortDest + "/v1/"

#--------------------------------------------------------------------------------------------------------------#
# Authenticating with Source Site Zerto APIs
#--------------------------------------------------------------------------------------------------------------#
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
# Generating Pairing Token from Destination Site
#--------------------------------------------------------------------------------------------------------------#
$baseURL = "https://" + $ZertoServerDest + ":" + $ZertoPortDest + "/v1/peersites"

# Authenticating with Zerto APIs
$ZertoHeaders = @{
    Accept            = 'application/json'
    'x-zerto-session' = $ReturnHeaders.'x-zerto-session'[0]
}
$RestMethodParameters = @{
    Headers                 = $ZertoHeaders
    ContentType             = 'application/json'
    ResponseHeadersVariable = 'ReturnHeaders'
    StatusCodeVariable      = 'ReturnStatusCode'
    SkipCertificateCheck    = $true
}
$URI = $baseURL + "/generatetoken"
Try {
    $PairingToken = Invoke-RestMethod @RestMethodParameters -Method "POST" -URI $URI
} Catch {
    Write-Host $_.Exception.ToString()
    $error[0] | Format-List -Force
}

#--------------------------------------------------------------------------------------------------------------#
# Building Zerto API string and invoking API on Source Site ZVM
#--------------------------------------------------------------------------------------------------------------#
$baseURL = "https://" + $ZertoServerSource + ":" + $ZertoPortSource + "/v1/"

# Authenticating with Source Site Zerto APIs
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
# Pair to Target Site using Pairing Token that was created earlier.
#--------------------------------------------------------------------------------------------------------------#
$baseURL = "https://" + $ZertoServerSource + ":" + $ZertoPortSource + "/v1/peersites"

# Authenticating with Zerto APIs
$ZertoHeaders = @{
    Accept            = 'application/json'
    'x-zerto-session' = $ReturnHeaders.'x-zerto-session'[0]
}
$RestMethodParameters = @{
    Headers                 = $ZertoHeaders
    ContentType             = 'application/json'
    ResponseHeadersVariable = 'ReturnHeaders'
    StatusCodeVariable      = 'ReturnStatusCode'
    SkipCertificateCheck    = $true
}
$URI = $baseURL
$body = @{
    "HostName" = "$ZertoServerDest"
    "Port"     = "$ZertoPairingPort"
    "Token"    = $PairingToken.Token
}
Try {
    $null = Invoke-RestMethod @RestMethodParameters -Method "POST" -URI $URI -Body ($body | ConvertTo-Json)
} Catch {
    Write-Host $_.Exception.ToString()
    $error[0] | Format-List -Force
}
