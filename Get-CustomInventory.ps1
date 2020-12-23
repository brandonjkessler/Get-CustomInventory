###### VARIABLE DECLARATION #######
$WarrantyEndDate = ''
$RegKey = 'CustomInv'
$RegKeyPath = "HKLM:\SOFTWARE\$RegKey"
if(!(Test-Path -Path "$RegKeyPath")){
    New-Item -Path "$RegKeyPath"
}


########## USER ##############
## TO DO ##
## Create a way to import CSV with Addresses
## Import CSV with Department IDs

## TO DO ##
## Get The Following:
## Currently Logged on User's info from AD. If unable to, get from User as input
## Phone Number from User input
## Address
## Building
## Floor
## Room/Cube
## Agency from Domain, or have user input if unable to
## Department
## Location
## Primary Device or Multi-User from User Input
## -If Multi-user machine, don't run on each new logon


###### Current User ######
$CurrentUser = $env:USERNAME


######### HARDWARE ##############
$CompInfo = Get-ComputerInfo

## TO DO ##
## Get The Following:

## Dock Serial Number
## Install Date (Display to EU)
## Asset Status (Display to EU)
## Schedule Number (For Leased Assets)

######### COMMENTS ###########
## Present to User, if all information is correct, do nothing
## User can select "Make Changes" and update any information

## Write to HKLM:\SOFTWARE\CustomInv


<#
Keys from previous script:

"ManufacturerTag"
"InstallDate"
"LocationCode"
"PhysicalAddress"
"AssignedUser"
"VendorName"
"VendorEmail"
"VendorPhone"
"Agency"
"Department"
"Status"
"SDTicket"
"Revision"
"Phone"

#>


###### MONITOR #######
## influenced by http://jeffwouters.nl/index.php/2016/11/powershell-find-the-manufacturer-model-and-serial-for-your-monitors/



$GetMonitor = Get-CimInstance -Namespace root\wmi -ClassName wmimonitorid 
$MonArray = @()

$GetMonitor | ForEach-Object {
	New-Object -TypeName psobject -Property @{
        Manufacturer = ($_.ManufacturerName -notmatch '^0$' | ForEach-Object {$_}) -join ""
        Name = ($_.UserFriendlyName -notmatch '^0$' | ForEach-Object {$_}) -join ""
        Serial = ($_.SerialNumberID -notmatch '^0$' | ForEach-Object {$_}) -join ""
    } | Where-Object {$_.Serial -ne 0} | ForEach-Object{$MonArray += $_}
}

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
if($AssetTag -match "20[0-9][0-9]-[0-1][0-9]"){ # Check to see if asset tag is set to lease or expiration date. YYYY-mm.
    $WarrantyEndDate = $AssetTag
} elseif($AssetTag -match "purchased") {
    ## TO DO ##
    ## Get Warranty Date from APIs ##
} elseif($AssetTag -match "unsupported") {
    $WarrantyEndDate = $AssetTag
}

###### COMPUTER DOMAIN ######
$DomainName = $CompInfo.CsDomain 
Set-ItemProperty -Path $RegKeyPath -Name "Domain" -Value "$DomainName"

###### Bitlocker Protection Status (ON/OFF) ######
$BitlockerStatus = (Get-BitLockerVolume -MountPoint C:).ProtectionStatus

###### WARRANTY END DATE ########
if(($WarrantyEndDate -ne $null) -or ($WarrantyEndDate -ne '')){
    Set-ItemProperty -Path $RegKeyPath -Name "WarrantyEndDate" -Value "$WarrantyEndDate"
} else {
    Set-ItemProperty -Path $RegKeyPath -Name "WarrantyEndDate" -Value "Unknown"
}

