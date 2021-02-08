#Requires -RunAsAdministrator

[CmdLetBinding()]
param (
    [Parameter(Mandatory=$true)]
        [ValidateScript({$Array = ($_ -split '\\|\/'); ($Array[0] -as [IPAddress]).AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork -and [string[]](0..32) -contains $Array[1]},
        ErrorMessage="Does not conform to CIDR notation x.x.x.x/nn")]
        [Alias('DestinationPrefix')]
        [string]$CIDR
    
)

#region ================= Utilities functions ================

$VMSwitch_Prefix = 'Hyper-V Host-Only #'

function Get-IPInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$CIDR
    )
    begin{}
    process{
        # Extract IPAddres, PrefixLength & Mask from CIDR
        if($CIDR){
            [IPAddress]$IPAddress = ($CIDR -split '\\|\/')[0]
            [int]$PrefixLength = ($CIDR -split '\\|\/')[1]
            [IPAddress]$Mask = [IPAddress]([string](4gb-([System.Math]::Pow(2,(32-$PrefixLength)))))
        }

        # Get Mask binary representation
        [int[]]$SplitMask = $Mask.GetAddressBytes()
        
        if(!$WildCard){
            [IPAddress]$WildCard = $SplitMask.ForEach({255 - $_}) -join '.'
        }
        if($WildCard){
            [int[]]$SplitWildCard = $WildCard.GetAddressBytes()
        }

        [IPAddress]$Subnet = $IPAddress.Address -band $Mask.Address
        [int[]]$SplitSubnet = $Subnet.GetAddressBytes()
        [IPAddress]$Broadcast = @(0..3).ForEach({[int]($SplitSubnet[$_]) + [int]($SplitWildCard[$_])}) -join '.'

        [string]$CIDR = "$($Subnet.IPAddressToString)/$PrefixLength"

        $Object = [pscustomobject][ordered]@{
            IPAddress = $IPAddress.IPAddressToString
            Mask = $Mask.IPAddressToString
            PrefixLength = $PrefixLength
            Subnet = $Subnet
            Broadcast = $Broadcast
            CIDR = $CIDR        
            PSTypeName = 'NetWork.IPCalcResult'
        }
        $Object

        [string[]]$DefaultProperties = @('IPAddress','Mask','PrefixLength','Subnet','Broadcast','CIDR')
        $PSPropertySet = New-Object -TypeName System.Management.Automation.PSPropertySet -ArgumentList @('DefaultDisplayPropertySet',$DefaultProperties)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]$PSPropertySet
        Add-Member -InputObject $Object -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers

    }
    end{

    }
}

#endregion ===================================================


#region ******************** Main ****************************
Clear-Host
Write-Host "Hyper-V - Create new Host-Only network"

$NetObject = Get-IPInfo -CIDR $CIDR

$IPSubnet = $NetObject.Subnet.IPAddressToString

if ($IPSubnet -in (Get-NetIPAddress | Select-Object -ExpandProperty IPAddress) -eq $True) {
     Write-Warning "'$IPSubnet' for static IP configuration already registered. Skipping"
     $if_alias = Get-NetIPAddress -IPAddress $IPSubnet | Select-Object -ExpandProperty InterfaceAlias

} else {
    $sw_index = 1
    $switches = (Get-VMSwitch | Where-Object { $_.Name -Match "${VMSwitch_Prefix}(.*)" } | 
        Sort-Object Name -desc | Select-Object -first 1)
    try {
        if ($switches) {
            $sw_index = [int]$Matches.1 + 1
        }
        $sw_name = "${VMSwitch_Prefix}${sw_index}"
        Write-Host "Creating '${sw_name}' switch on host ..."
        $new_switch = New-VMSwitch -SwitchName "${sw_name}" -SwitchType Internal
        
        $if_alias = (Get-NetAdapter | Where-Object {$_.Name -like "*${sw_name}*"} | Select-Object -ExpandProperty Name)
        Write-Host "Registering new IP address ${IPSubnet} on ${if_alias} ..."
        New-NetIPAddress -IPAddress $IPSubnet -PrefixLength $NetObject.PrefixLength -InterfaceAlias $if_alias
        
        Write-Host -ForegroundColor DarkGreen "`n`nSuccess!"
        ${sw_name}
    } catch {
        if($new_switch) {
            Write-Warning "Deleting '${sw_name}'"
            Get-VMSwitch -Name "${sw_name}" | Remove-VMSwitch
            Write-Warning "Done"
        }
        Write-Host -ForegroundColor DarkRed "`n`nKO"
    }
}