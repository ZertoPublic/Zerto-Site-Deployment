#Requires -PSEdition Core

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
