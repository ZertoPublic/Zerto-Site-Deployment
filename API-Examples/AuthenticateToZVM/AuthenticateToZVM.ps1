#Requires -PSEdition Core

<#
.SYNOPSIS
    This script will authenticate you to a specified Zerto Virtual Manager (ZVM) and provide you with the x-zerto-session header that will be required in subsequent commands as a header value for authentication validation.
.DESCRIPTION
    This script requires some variables to be set for the ZVM Hostname/IP address, ZVM TCP Port (if not the default), as well as authentication info.
.VERSION
    Applicable versions of Zerto Products script has been tested on.
    - Zerto 6.5+ on vSphere 6.7+
    - Zerto 7.5+ on vSphere 7.0+
    Note: For more information on supported versions of Zerto with specific hypervisor versions, see the Zerto Interoperability Matrix (http://s3.amazonaws.com/zertodownload_docs/Latest/Zerto%20Virtual%20Replication%20Operability%20Matrix.pdf)
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
$ZertoServer = "GOES HERE"  # Enter the Hostname/IP of the Zerto Virtual Manager (ZVM) to connect to
$ZertoPort = "9669" # Only Update if using a Nonstandard port.
$ZertoUserName = "GOES HERE"    # Enter the ZVM username
$ZertoPassword = "GOES HERE" | ConvertTo-SecureString -AsPlainText  # Enter the ZVM Password
$ZertoCredentials = [PSCredential]::New($ZertoUserName, $ZertoPassword)

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
#Extracting x-zerto-session from the response and returning it.
#--------------------------------------------------------------------------------------------------------------#
$ReturnHeaders.'x-zerto-session'[0]

