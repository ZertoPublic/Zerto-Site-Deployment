# Zerto Deployment Scripts

This repository consists of the following example scripts designed to deploy and configure a new Zerto installation. There are two groups of examples. 

API-Examples - Leverages the Zerto REST APIs and PowerShell Core.

APIWrapper-Examples - Leverages the ZertoAPIWrapper and PowerShell Core.

- AuthenticateToZVM.ps1 (API Only) - This script will authenticate you to a specified Zerto Virtual Manager (ZVM) and provide you with the x-zerto-session header that will be required in subsequent commands as a header value for authentication validation.
- LicenseZVM.ps1 - This script will apply a specified license key to a Zerto Virtual Manager (ZVM).
- PairZertoSites.ps1 - This script will pair Source and Target Zerto Virtual Managers (ZVMs).
- BulkVRADeployment.ps1 - This script automates the deployment of VRAs based on the hosts in the specified CSV file using the Zerto API. The CSV is required to be filled out   before running the script in order to utilize the necessary vCenter resources when creating the VRAs. Please note this script is intended to be used only with ESXi hosts 5.5 and newer. The script doesn't call for a host root password and is instead using the Zerto VRA VIB deployment that was introduced in ZVR 4.5.

## Legal Disclaimer

This script is an example script and is not supported under any Zerto support program or service. The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
