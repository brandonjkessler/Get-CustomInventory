########## USER ##############
## TO DO ##
## Create a way to import CSV with Addresses
## Import CSV with Department IDs

## TO DO ##
## Get The Follwing:
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
## Computer Name (Display to EU)
$env:COMPUTERNAME
## Computer Serial Number (Display to EU)
(Get-ComputerInfo).BiosSeralNumber
## All connected Monitor Serial Numbers
## Dock Serial Number
## Asset Tag (for Expiration of Lease or Purchased)
## Asset Family (Chassis Type)
## Manufacturer (Display to EU)
## Computer Model (Display to EU)
## Processor
## RAM
## SSD size
## Bitlocker Enabled
## OS (Display to EU)
(Get-ComputerInfo).OsName
## Build Version (Display to EU)
(Get-ComputerInfo).OsVersion #10.0.19042
(Get-ComputerInfo).WindowsVersion #2009, 1909
## Install Date (Display to EU)
## Warranty Date (Display to EU)
(Get-CimInstance -ClassName Win32_SystemEnclosure).SMBIOSAssetTag
## MAC Address (Display to EU)
## Domain (Display to EU)
(Get-ComputerInfo).CsDomain 
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