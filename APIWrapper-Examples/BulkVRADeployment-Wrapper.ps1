#Requires -PSEdition Core
#Requires -Module ZertoApiWrapper

#--------------------------------------------------------------------------------------------------------------#
# Configure the variables below
#--------------------------------------------------------------------------------------------------------------#

$ESXiHostCSV = ".\BulkVRADeployment.csv"
$ZertoServer = "GOES HERE"  # Enter the Hostname/IP of the Zerto Virtual Manager (ZVM) to connect to
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
