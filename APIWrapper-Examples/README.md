# Zerto Deployment Scripts

This repository consists of the following example scripts designed to deploy and configure a new Zerto installation. These examples leverage the ZertoAPIWrapper and PowerShell Core.


# LicenseZVM-Wrapper.ps1
This script will apply a specified license key to a Zerto Virtual Manager (ZVM).

## Prerequisites

Environment Requirements:

- PowerShell Core
- Zerto 6.5+

Script Requirements:

- Zerto License Key
- ZVM ServerName/IP & Port
- Username and password with permission to access the API of the ZVM

## Running Script

Once the necessary requirements have been completed select an appropriate host to run the script from. To run the script type the following:

.\LicenseZVM-Wrapper.ps1



# PairZertoSites-Wrapper.ps1

This script will pair Source and Target Zerto Virtual Managers (ZVMs).

## Prerequisites

Environment Requirements:

- PowerShell Core
- Zerto 6.5+

Script Requirements:

- Source Site ZVM ServerName/IP & Port
- Target Site ZVM ServerName/IP & Port
- Source and Target ZVM TCP Port (if not the default)
- Pairing Port (if not the default)
- Username and password with permission to access the API of the source and target ZVMs

## Running Script

Once the necessary requirements have been completed select an appropriate host to run the script from. To run the script type the following:

.\PairZertoSites-Wrapper.ps1



# BulkVRADeployment-Wrapper.ps1

This script automates the deployment of VRAs based on the hosts in the specified CSV file using the Zerto API. The CSV is required to be filled out   before running the script in order to utilize the necessary vCenter resources when creating the VRAs. Please note this script is intended to be used only with ESXi hosts 5.5 and newer. The script doesn't call for a host root password and is instead using the Zerto VRA VIB deployment that was introduced in ZVR 4.5.

## Prerequisites

Environment Requirements:

- PowerShell Core
- Zerto 6.5+
- vSphere 5.5+
- Network access to the Zerto Virtual Manager(s) (ZVMs), use the target site ZVM for storage info to be populated

Script Requirements:

- ZVM ServerName/IP, Username and Password with permission to access the API of the ZVM
- BulkVRADeployment.csv required info completed
- BulkVRADeployment.csv accessible by host running script

## Running Script

Once the necessary requirements have been completed select an appropriate host to run the script from. To run the script type the following:

.\BulkVRADeployment-Wrapper.ps1



### Legal Disclaimer

This script is an example script and is not supported under any Zerto support program or service. The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
