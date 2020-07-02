#Requires -PSEdition Core
#Requires -Module ZertoApiWrapper

<#
.SYNOPSIS
   This script will pair Source and Target Zerto Virtual Managers (ZVMs).
.DESCRIPTION
   This script requires some variables to be set for the Source and Target ZVM Hostname/IP address, Source and Target ZVM TCP Port (if not the default), Pairing Port (if not the default), as well as authentication info.
.VERSION
   Applicable versions of Zerto Products script has been tested on:
   Zerto Version 7.5 and above.
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

$ZertoUserName = "GOES HERE" # Enter the ZVM username
$ZertoPassword = "GOES HERE" | ConvertTo-SecureString -AsPlainText  # Enter the ZVM Password
$ZertoCredentials = [PSCredential]::New($ZertoUserName, $ZertoPassword)
$ZertoServerSource = "GOES HERE" # Enter the hostname or IP address of your source ZVM
$ZertoServerTarget = "GOES HERE" # Enter the hostname or IP address of your target ZVM
$ZertoPortSource = "9669" # Only Update if using a Nonstandard port.
$ZertoPortTarget = "9669" # Only Update if using a Nonstandard port.
$ZertoPairingPort = "9071"  # Only Update if using a Nonstandard port.

#--------------------------------------------------------------------------------------------------------------#
# Generating Pairing Token from Target ZVM
#--------------------------------------------------------------------------------------------------------------#

# Establishes a connection to the Target ZVM
Connect-ZertoServer -zertoServer $ZertoServerTarget -zertoPort $ZertoPortTarget -credential $ZertoCredentials

# Generates a new pairing token to be used during pairing ZVM to ZVM operations.
$PairingToken = New-ZertoPairingToken

# Disconnects the current session from the Target ZVM
Disconnect-ZertoServer

#--------------------------------------------------------------------------------------------------------------#
# Pairs the Source ZVM to the Target ZVM using Pairing Token from Target ZVM
#--------------------------------------------------------------------------------------------------------------#

# Establishes a connection to the Source ZVM
Connect-ZertoServer -zertoServer $ZertoServerSource -zertoPort $ZertoPortSource -credential $ZertoCredentials

# Pairs the Source ZVM to the Target ZVM using Pairing Token from Target Site
Add-ZertoPeerSite -targetHost $ZertoServerTarget -targetPort $ZertoPairingPort -token $PairingToken.Token

# Disconnects the current session from the Source ZVM
Disconnect-ZertoServer
