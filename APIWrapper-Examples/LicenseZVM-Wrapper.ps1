#Requires -PSEdition Core

#--------------------------------------------------------------------------------------------------------------#
# Configure the variables below
#--------------------------------------------------------------------------------------------------------------#

$LicenseKey = "GOES HERE"  # Enter your Zerto License Key here
$ZertoUserName = "GOES HERE" # Enter the ZVM username
$ZertoPassword = "GOES HERE" | ConvertTo-SecureString -AsPlainText  # Enter the ZVM Password
$ZertoCredentials = [PSCredential]::New($ZertoUserName, $ZertoPassword)
$ZertoServer = "GOES HERE" # Enter the hostname or IP address of your source side ZVM
$ZertoPort = "9669" # Only Update if using a Nonstandard port.

#--------------------------------------------------------------------------------------------------------------#
# Generating Pairing Token from Target Site
#--------------------------------------------------------------------------------------------------------------#

# Establishes a connection to a ZVM
Connect-ZertoServer -zertoServer $ZertoServer -zertoPort $ZertoPort -credential $ZertoCredentials

# Updates the Zerto License with a new key
Set-ZertoLicense -licenseKey $LicenseKey

# Disconnects the current session from the ZVM
Disconnect-ZertoServer
