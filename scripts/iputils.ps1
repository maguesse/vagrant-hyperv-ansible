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