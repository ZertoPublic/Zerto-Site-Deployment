# Pair Zerto Sites

This script will pair Source and Target Zerto Virtual Managers (ZVMs).

## Prerequisites

Environment Requirements:

- PowerShell Core
- Zerto 6.5+
- ESXi 5.5+ for VMware VIB deployment support

Script Requirements:

- Source and Target ZVM TCP Port (if not the default)
- Source Site ZVM ServerName/IP & Port
- Target Site ZVM ServerName/IP & Port
- Username and password with permission to access the API of the source and target ZVMs

## Running Script

Once the necessary requirements have been completed select an appropriate host to run the script from. To run the script type the following:

.\PairZertoSites.ps1

## Legal Disclaimer

This script is an example script and is not supported under any Zerto support program or service. The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
