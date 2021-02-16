# Get-CustomInventory

## PREREQUISITES
* Run as Admin

## SYNOPSIS
Gathers computer information and writes to registry keys.

## DESCRIPTION
Gathers information on the computer and writes it to the registry.  
This includes information on some peripherals attached.  
While you can pull this data from other sources, this allows us to pull our data from one source.

## PARAMETERS
* RegistryKeyPath
  * Path for the registry key location. Default is 'HKLM:\SOFTWARE'
* RegistryKey
  * Custom Registry Key. Default is 'CustomInv'

## EXAMPLES
    Get-CustomInventory

    Get-CustomInventory -RegistryKeyPath 'HKLM:\SOFTWARE' -RegistryKey 'OrgName'

## KEYS
* Monitor[0]SN
* ComputerName
* SerialNumber
* Manufacturer
* Model
* AssetFamily
* Processor
* RAM
* HDDSize
* HDDSizeFormatted
* NetworkCard
* Wifi[0]Mac
* Nic[0]Mac
* OperatingSystem
* OSBuildVersion
* AssetTag
* Domain
* BitlockerStatus
* DateRun





