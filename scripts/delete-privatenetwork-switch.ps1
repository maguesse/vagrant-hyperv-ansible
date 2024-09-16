#Requires -RunAsAdministrator

[CmdLetBinding()]
param (
    [Parameter(Mandatory=$true)]
        [ValidateScript({$Array = ($_ -split '\\|\/'); ($Array[0] -as [IPAddress]).AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork -and [string[]](0..32) -contains $Array[1]},
        ErrorMessage="Does not conform to CIDR notation x.x.x.x/nn")]
        [Alias('DestinationPrefix')]
        [string]$CIDR   
)

. ".\iputils.ps1"

$VMSwitch_Prefix = 'Hyper-V Host-Only #'

Write-Host "Hyper-V - Removing Host-Only network"

$NetObject = Get-IPInfo -CIDR $CIDR
$IPAddress= $NetObject.IPAddress

if ($IPAddress -in (Get-NetIPAddress | Select-Object -ExpandProperty IPAddress) -eq $True) {
     $if_alias = Get-NetIPAddress -IPAddress $IPAddress | Select-Object -ExpandProperty InterfaceAlias
     
     if ($if_alias -like "*${VMSwitch_Prefix}*") {
         # Get the VMSwitch
         
         # Check if attached to a VM
     } else {
         Write-Warning "${IPAddress} is not associated with a VMSwitch (${if_alias}). Skipping..."
    }

} else {
    Write-Warning "'${IPAddress}' for static IP configuration is not registered. Skipping"
}