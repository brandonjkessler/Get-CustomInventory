<#
    .SYNOPSIS
    Gathers computer information and writes to registry keys.

    .DESCRIPTION
    Gathers information on the computer and writes it to the registry.  
    This includes information on some peripherals attached.

    .PARAMETER RegistryKeyPath
    Path for the registry key location. Default is 'HKLM:\SOFTWARE'

    .PARAMETER RegistryKey
    Custom Registry Key. Default is 'CustomInv'
    

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    Get-CustomInventory

    .EXAMPLE
    Get-CustomInventory -RegistryKeyPath 'HKLM:\SOFTWARE' -RegistryKey 'OrgName'

    .LINK
    
#>


param(
    [Parameter(ValueFromPipelineByPropertyName,HelpMessage='Path where you want to put a custom registry key.')]
    [String]
    $RegistryPath = 'HKLM:\SOFTWARE',
    [Parameter(ValueFromPipelineByPropertyName,HelpMessage='Custom registry key to hold all the information.')]
    [String]
    $RegistryKey = 'CustomInv'
)



###### VARIABLE DECLARATION #######
$WarrantyEndDate = ''
$RegKeyPath = "$RegistryPath\$RegistryKey"
if(!(Test-Path -Path "$RegKeyPath")){
    New-Item -Path "$RegKeyPath"
}
$Date = Get-Date




######### HARDWARE ##############
$CompInfo = Get-ComputerInfo


###### MONITOR #######
## influenced by http://jeffwouters.nl/index.php/2016/11/powershell-find-the-manufacturer-model-and-serial-for-your-monitors/

function Decode {
    If ($args[0] -is [System.Array]) {
        [System.Text.Encoding]::ASCII.GetString($args[0])
    }
    Else {
        "Not Found"
    }
}

$GetMonitor = Get-CimInstance -Namespace root\wmi -ClassName wmimonitorid 
$MonArray = @()

$GetMonitor | ForEach-Object {
        New-Object -TypeName psobject -Property @{
            Manufacturer = Decode $_.ManufacturerName -notmatch '^0$'
            Model = Decode $_.UserFriendlyName -notmatch '^0$'
            Serial = Decode $_.SerialNumberID -notmatch '^0$'
        } | Where-Object {$_.Serial -ne 0} | ForEach-Object{$MonArray += $_}          
} # End ForEach-Object

$MonArray | ForEach-Object{
    if($MonArray.Length -lt 1){ # Test if monitors attached
        Write-Output 'NO MONITORS!'
    } else {
        Set-ItemProperty -Path $RegKeyPath -Name "$('Monitor' + $($MonArray.Indexof($_) + 1) + 'SN')" -Value "$($_.Serial)" # Set Property
    }
}

###### COMPUTER NAME ######
$CompName = $env:COMPUTERNAME
Set-ItemProperty -Path $RegKeyPath -Name "ComputerName" -Value "$CompName"

###### COMPUTER SERIAL NUMBER ######
$CompSN = $CompInfo.BiosSeralNumber
Set-ItemProperty -Path $RegKeyPath -Name "SerialNumber" -Value "$CompSN"

###### COMPUTER MANUFACTURER/MODEL ######
$CompManu = $CompInfo.CsManufacturer
$CompMod = $CompInfo.CsModel

Set-ItemProperty -Path $RegKeyPath -Name "Manufacturer" -Value "$CompManu"
Set-ItemProperty -Path $RegKeyPath -Name "Model" -Value "$CompMod"


###### ASSET FAMILY ########
$CompFamily = $CompInfo.CsPCSystemType
Set-ItemProperty -Path $RegKeyPath -Name "AssetFamily" -Value "$CompFamily"

###### COMPUTER PROCESSOR ######
$CompProcessor = ($CompInfo.CsProcessors).Name
Set-ItemProperty -Path $RegKeyPath -Name "Processor" -Value "$CompProcessor"

###### COMPUTER RAM #######
$CompRAM = (($CompInfo.OsTotalVisibleMemorySize)/1024)/1024
$CompRAM = [Math]::Round([Math]::Ceiling($CompRAM))
Set-ItemProperty -Path $RegKeyPath -Name "RAM" -Value "$CompRAM"

###### SSD SIZE ######
$SSDSize = (Get-Disk -Number 0).Size
$SSDSizeFormatted = [Math]::Round([Math]::Floor($SSDSize/1024/1024/1024))
$SSDSize = [Math]::Round([Math]::Floor($SSDSize/1000/1000/1000))
Set-ItemProperty -Path $RegKeyPath -Name "HDDSize" -Value "$SSDSize"
Set-ItemProperty -Path $RegKeyPath -Name "HDDSizeFormatted" -Value "$SSDSizeFormatted"


###### NETWORK INTERFACES #######
[Array]$wifiNetArray = @()
[Array]$nicNetArray = @()
$CIMNetAdapters = Get-CimInstance -ClassName CIM_NetworkAdapter | Where-Object{` # Get the network adapters and then get rid of extra stuff
    ($_.name -notlike "*bluetooth*") -and `
    ($_.name -notlike "*microsoft*") -and `
    ($_.name -notlike "*broadband*") -and `
    ($_.name -notlike "*snapdragon*") -and `
    ($_.name -notlike "*cisco*") -and `
    ($_.name -notlike "*usb*") -and `
    ($_.name -notlike "*wan*")}

$CIMNetAdapters | ForEach-Object{ ## Assign NICs to correct location
    if(($_.Name -match 'wi-fi') -or ($_.Name -match 'wireless')){
        $wifiNetArray += $_
    } elseif ($_.Name -match 'ethernet'){
        $nicNetArray += $_
    }
}

$nics = ''
$CIMNetAdapters | ForEach-Object { ## Get the detected NIC names and put them in their own reg key
    $nics += "$($_.Name)" + '; '
}

Set-ItemProperty -Path $RegKeyPath -Name "NetworkCard" -Value "$nics"

$wifiNetArray | ForEach-Object{
    if($wifiNetArray.Length -lt 1){ # Test if Wifi Detected
        Write-Output 'NO WIFI'
    } else {
        Set-ItemProperty -Path $RegKeyPath -Name "$('Wifi' + $($wifiNetArray.Indexof($_) + 1) + 'Mac')" -Value "$($_.MacAddress)" # Set Property
    }
}

$nicNetArray | ForEach-Object{
    if($nicNetArray.Length -lt 1){ # Test if Wifi Detected
        Write-Output 'NO NIC'
    } else {
        Set-ItemProperty -Path $RegKeyPath -Name "$('Nic' + $($nicNetArray.Indexof($_) + 1) + 'Mac')" -Value "$($_.MacAddress)" # Set Property
    }
}




###### OS NAME ######
$OSName = $CompInfo.OsName
Set-ItemProperty -Path $RegKeyPath -Name "OperatingSystem" -Value "$OSName"

###### OS BUILD VERSION ######
$OSBuild = $CompInfo.WindowsVersion #2009, 1909
Set-ItemProperty -Path $RegKeyPath -Name "OSBuildVersion" -Value "$OSBuild"

###### ASSET TAG ######
$AssetTag = (Get-CimInstance -ClassName Win32_SystemEnclosure).SMBIOSAssetTag
Set-ItemProperty -Path $RegKeyPath -Name "AssetTag" -Value "$AssetTag"

###### COMPUTER DOMAIN ######
$DomainName = $CompInfo.CsDomain 
Set-ItemProperty -Path $RegKeyPath -Name "Domain" -Value "$DomainName"

###### CURRENT OU #######
$ADPath = ((([adsisearcher]"(&(objectCategory=Computer)(name=$env:COMPUTERNAME))").findall()).properties).distinguishedname
Set-ItemProperty -Path $RegKeyPath -Name 'ADPath' -Value "$ADPath"


###### Bitlocker Protection Status (ON/OFF) ######
$BitlockerStatus = (Get-BitLockerVolume -MountPoint C:).ProtectionStatus
Set-ItemProperty -Path $RegKeyPath -Name "BitlockerStatus" -Value "$BitlockerStatus"


####### DATE RUN #############
Set-ItemProperty -Path $RegKeyPath -Name "DateRun" -Value "$Date"
