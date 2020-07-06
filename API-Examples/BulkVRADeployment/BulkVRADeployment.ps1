#Requires -PSEdition Core

<#
.SYNOPSIS
   This script automates the deployment of VRAs for the hosts in the specified CSV file using the Zerto API to complete the process
.DESCRIPTION
   The script requires a user to prepopulate the VRADeploymentESXiHosts.csv with the necessary vCenter resources the VRA will utilize including the ESXi Host, Datastore,
   vSwitch / vDS Port Group, Memory, IP Address, Gateway, and Subnet for the VRA. These vCenter resources will then be utilized
.VERSION
   Applicable versions of Zerto Products script has been tested on.  Unless specified, all scripts in repository will be 5.0u3 and later.  If you have tested the script on multiple
   versions of the Zerto product, specify them here.  If this script is for a specific version or previous version of a Zerto product, note that here and specify that version
   in the script filename.  If possible, note the changes required for that specific version.
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
$ESXiHostCSV = ".\BulkVRADeployment.csv"
$ZertoPort = "9669" # Only Update if using a Nonstandard port.
$ZertoUserName = "GOES HERE"    # Enter the ZVM username
$ZertoPassword = "GOES HERE" | ConvertTo-SecureString -AsPlainText  # Enter the ZVM Password
$ZertoCredentials = [PSCredential]::New($ZertoUserName, $ZertoPassword)

#------------------------------------------------------------------------------#
# Nothing to configure below this line
#------------------------------------------------------------------------------#

# Import configuration data from csv file defined in $ESXiHostCSV above
$ESXiHostCSVImport = Import-Csv $ESXiHostCSV

# Identify Unique Zerto Virtual Managers from CSV file
$ZVMName = $ESXiHostCSVImport | Select-Object ZVMName -Unique

foreach ($ZVM in $ZVMName) {

    #-------------------------------------------------------------------------------#
    # Building Zerto API string and invoking API
    #-------------------------------------------------------------------------------#

    $ZertoServer = $ZVM.ZVMName
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

    #Extracting x-zerto-session from the response, and adding it to the actual API
    $ZertoHeaders['x-zerto-session'] = $ReturnHeaders.'x-zerto-session'[0]

    # Get SiteIdentifier for getting required resource identifiers
    $URI = $BaseURL + "localsite"
    $SiteIdentifier = (Invoke-RestMethod @RestMethodParameters -Uri $URI).SiteIdentifier

    # Get Site Networks for name to identifier translation
    $URI = "{0}{1}/{2}/{3}" -f $baseURL, "virtualizationsites", $SiteIdentifier, 'networks'
    $SiteNetworks = Invoke-RestMethod @RestMethodParameters -Uri $URI
    $NetworksMap = @{ }
    foreach ($network in $SiteNetworks) {
        $NetworksMap.Add($network.VirtualizationNetworkName, $network.NetworkIdentifier)
    }

    # Get Site Hosts for name to identifier translation
    $URI = "{0}{1}/{2}/{3}" -f $baseURL, "virtualizationsites", $SiteIdentifier, 'hosts'
    $SiteHosts = Invoke-RestMethod @RestMethodParameters  -Uri $URI
    $HostsMap = @{ }
    foreach ($esxHost in $SiteHosts) {
        $HostsMap.Add($esxHost.VirtualizationHostName, $esxHost.HostIdentifier)
    }

    # Get Site datastores for name to identifier translation
    $URI = "{0}{1}/{2}/{3}" -f $baseURL, "virtualizationsites", $SiteIdentifier, 'datastores'
    $SiteDatastores = Invoke-RestMethod @RestMethodParameters  -Uri $URI
    $DatastoresMap = @{ }
    foreach ($ds in $SiteDatastores) {
        $DatastoresMap.Add($ds.DatastoreName, $ds.DatastoreIdentifier)
    }

    #------------------------------------------------------------------------------#
    # Install Zerto VRA to each host specified in the imported CSV file
    #------------------------------------------------------------------------------#

    $HostVras = $ESXiHostCSVImport | Where-Object { $_.ZVMName -like $ZVM.ZVMName }
    foreach ($VRA in $HostVras) {

        $URI = $BaseURL + 'vras'

        # Creating JSON Body for API settings
        $RequestBody = @{
            DatastoreIdentifier              = $DatastoresMap[$VRA.DatastoreName]
            GroupName                        = $VRA.VRAGroupName
            HostIdentifier                   = $HostsMap[$VRA.ESXiHostName]
            MemoryInGb                       = $VRA.MemoryInGB
            NetworkIdentifier                = $NetworksMap[$VRA.PortGroupName]
            UsePublicKeyInsteadOfCredentials = $true
            VraNetworkDataApi                = @{
                DefaultGateway            = $VRA.DefaultGateway
                SubnetMask                = $VRA.SubnetMask
                VraIPAddress              = $VRA.VRAIPAddress
                VraIPConfigurationTypeApi = "Static"
            }
        }

        Write-Verbose "Executing $($RequestBody | ConvertTo-Json)"

        # Trying API installation command
        Try {
            Invoke-RestMethod @RestMethodParameters -URI $URI -Method POST -Body ($RequestBody | ConvertTo-Json)
        } Catch {
            Write-Host $_.Exception.ToString()
            $error[0] | Format-List -Force
        }

        # End of per Host operations below

    }

    # Remove the Session from the ZVM
    $URI = $baseURL + 'Session'
    $null = Invoke-RestMethod @RestMethodParameters -Uri $URI -Method DELETE

}
