#Requires -PSEdition Core
#Requires -Module ZertoApiWrapper

<#
.SYNOPSIS
   This script automates the deployment of VRAs for the hosts in the specified CSV file using the Zerto API to complete the process
.DESCRIPTION
   The script requires a user to prepopulate the BulkVRADeployment.csv with the necessary vCenter resources the VRA will utilize including the ESXi Host, Datastore, vSwitch / vDS Port Group, Memory, IP Address, Gateway, and Subnet for the VRA. These vCenter resources will then be utilized
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

#--------------------------------------------------------------------------------------------------------------#
# Configure the variables below
#--------------------------------------------------------------------------------------------------------------#

$ESXiHostCSV = ".\BulkVRADeployment.csv"
$ZertoPort = "9669" # Only Update if using a Nonstandard port.
$ZertoUserName = "GOES HERE"    # Enter the ZVM username
$ZertoPassword = "GOES HERE" | ConvertTo-SecureString -AsPlainText  # Enter the ZVM Password
$ZertoCredentials = [PSCredential]::New($ZertoUserName, $ZertoPassword)

#--------------------------------------------------------------------------------------------------------------#
# Importing the CSV of ESXi hosts to deploy VRA to
#--------------------------------------------------------------------------------------------------------------#

$ESXiHostCSVImport = Import-Csv $ESXiHostCSV

#--------------------------------------------------------------------------------------------------------------#
#  Identify Unique Zerto Virtual Managers from CSV file
#--------------------------------------------------------------------------------------------------------------#
$ZVMName = $ESXiHostCSVImport | Select-Object ZVMName -Unique

foreach ($ZVM in $ZVMName) {

   # Establishes a connection to a ZVM
   Connect-ZertoServer -zertoServer $ZVM.ZVMName -zertoPort $ZertoPort -credential $ZertoCredentials

   #--------------------------------------------------------------------------------------------------------------#
   #  Install Zerto VRA to each host specified in the imported CSV file
   #--------------------------------------------------------------------------------------------------------------#

   $HostVras = $ESXiHostCSVImport | Where-Object { $_.ZVMName -like $ZVM.ZVMName }
   foreach ($VRA in $HostVras) {

      # Defining VRA Settings to use
      $VRASettings = @{
         hostName       = $VRA.ESXiHostName
         datastoreName  = $VRA.DatastoreName
         networkName    = $VRA.PortGroupName
         groupName      = $VRA.VRAGroupName
         memoryInGB     = $VRA.MemoryInGB
         vraIpAddress   = $VRA.VRAIPAddress
         subnetMask     = $VRA.SubnetMask
         defaultGateway = $VRA.DefaultGateway
      }

      # Installing VRA on each host specified in the imported CSV file using defined settings
      Install-ZertoVra @VRASettings

   }

}

# Disconnects the current session from the ZVM
Disconnect-ZertoServer
