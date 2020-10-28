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
## Computer Serial Number (Display to EU)
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
## Build Version (Display to EU)
## Install Date (Display to EU)
## Warranty Date (Display to EU)
## MAC Address (Display to EU)
## Domain (Display to EU)
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