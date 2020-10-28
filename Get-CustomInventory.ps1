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
## http://jeffwouters.nl/index.php/2016/11/powershell-find-the-manufacturer-model-and-serial-for-your-monitors/
$GetMonitor = Get-CimInstance -Namespace root\wmi -ClassName wmimonitorid 
$MonArray = @()

$GetMonitor | ForEach-Object {
	New-Object -TypeName psobject -Property @{
        Manufacturer = ($_.ManufacturerName -notmatch '^0$' | ForEach-Object {[char]$_}) -join ""
        Name = ($_.UserFriendlyName -notmatch '^0$' | ForEach-Object {[char]$_}) -join ""
        Serial = ($_.SerialNumberID -notmatch '^0$' | ForEach-Object {[char]$_}) -join ""
    } | Where-Object {$_.Serial -ne 0} | ForEach-Object{$MonArray += $_}
}

#Testing
if($MonArray.Length -gt 1){
    Write-Output 'MOAR MONITORS!'
} else {
    Write-Output 'THERE CAN BE ONLY ONE!'
}

###### Computer Name ######
$CompName = $env:COMPUTERNAME

###### Computer Serial Number ######
$CompSN = (Get-ComputerInfo).BiosSeralNumber

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

###### Domain ######
$DomainName = (Get-ComputerInfo).CsDomain 

###### Bitlocker Protection Status (ON/OFF) ######
$BitlockerStatus = (Get-BitLockerVolume -MountPoint C:).ProtectionStatus

###### SSD Size ######
$SSDSize = ((Get-Disk -Number 0).Size)/1024/1024/1024

###### Current User ######
$CurrentUser = $env:USERNAME