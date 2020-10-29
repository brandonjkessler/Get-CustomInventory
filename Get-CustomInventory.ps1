###### VARIABLE DECLARATION #######
$WarrantyEndDate = ''
$RegKey = 'CustomInv'
$RegKeyPath = "HKLM:\SOFTWARE\$RegKey"


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

## TO DO ##
## Get The Following:

## Dock Serial Number
## Asset Family (Chassis Type)
## Install Date (Display to EU)
## Warranty Date (Display to EU)
## MAC Address (Display to EU)
## Asset Status (Display to EU)
## Schedule Number (For Leased Assets)

######### COMMENTS ###########
## Present to User, if all information is correct, do nothing
## User can select "Make Changes" and update any information

## Write to HKLM:\SOFTWARE\CustomInv


<#
Keys from previous script:

"NetworkCard"
"ComputerName"
"AssetFamily"
"Model"
"Manufacturer"
"ProccessorInfo"
"RAM"
"HDDSize"
"SerialNumber"
"OperatingSystem"
"ManufacturerTag"
"InstallDate"
"WarrantyEndDate"
"LocationCode"
"PhysicalAddress"
"AssignedUser"
"VendorName"
"VendorEmail"
"VendorPhone"
"Agency"
"Department"
"Status"
"Domain"
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
        Manufacturer = ($_.ManufacturerName -notmatch '^0$' | ForEach-Object {[char]$_}) -join ""
        Name = ($_.UserFriendlyName -notmatch '^0$' | ForEach-Object {[char]$_}) -join ""
        Serial = ($_.SerialNumberID -notmatch '^0$' | ForEach-Object {[char]$_}) -join ""
    } | Where-Object {$_.Serial -ne 0} | ForEach-Object{$MonArray += $_}
}

$MonArray | ForEach-Object{
    if($MonArray.Length -lt 1){ # Test if monitors attached
        Write-Output 'NO MONITORS!'
    } else {
        Set-ItemProperty -Path $RegKeyPath -Name "$('Monitor' + $($MonArray.Indexof($_) + 1))" -Value "$($_.Serial)" # Set Property
    }
}

###### COMPUTER NAME ######
$CompName = $env:COMPUTERNAME
Set-ItemProperty -Path $RegKeyPath -Name "ComputerName" -Value "$CompName"

###### Computer Serial Number ######
$CompSN = (Get-ComputerInfo).BiosSerialNumber

###### Computer Manufacturer/Model ######
$CompManu = (Get-ComputerInfo).CsManufacturer
$CompMod = (Get-ComputerInfo).CsModel

###### Computer Processor ######
$CompProcessor = (Get-ComputerInfo).CsProcessors

###### Computer RAM #######
$CompRAM = (((Get-ComputerInfo).OsTotalVisibleMemorySize)/1024)/1024

###### OS Name ######
$OSName = (Get-ComputerInfo).OsName

###### OS Build Version ######
$OSBuild = (Get-ComputerInfo).WindowsVersion #2009, 1909

###### Asset Tag ######
$AssetTag = (Get-CimInstance -ClassName Win32_SystemEnclosure).SMBIOSAssetTag
if($AssetTag -match "20[0-9][0-9]-[0-1][0-9]"){ # Check to see if asset tag is set to lease or expiration date
    $WarrantyEndDate = $AssetTag
} elseif($AssetTag -match "purchased") {
    ## TO DO ##
    ## Get Warranty Date from APIs ##
} elseif($AssetTag -match "unsupported") {
    $WarrantyEndDate = $AssetTag
}

###### Domain ######
$DomainName = (Get-ComputerInfo).CsDomain 

###### Bitlocker Protection Status (ON/OFF) ######
$BitlockerStatus = (Get-BitLockerVolume -MountPoint C:).ProtectionStatus

###### SSD Size ######
$SSDSize = ((Get-Disk -Number 0).Size)/1024/1024/1024

###### WARRANTY END DATE ########
if(($WarrantyEndDate -ne $null) -or ($WarrantyEndDate -ne '')){
    Set-ItemProperty -Path $RegKeyPath -Name "WarrantyEndDate" -Value "$WarrantyEndDate"
} else {
    Set-ItemProperty -Path $RegKeyPath -Name "WarrantyEndDate" -Value "Unknown"
}

