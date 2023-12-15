# Windows_Toolbox

On Windows and don't know what's up with the hardware and software tied to it?<br>
This repo holds a relatively small list of PowerShell and CMD commands for enumerating the host.

#
---
#

```PowerShell
hostname

Get-ComputerInfo | select TimeZone,
    OsLocalDateTime,OsLastBootUpTime,OsUptime,
    OsNumberOfUsers,CsUserName,OsRegisteredUser,
    OsOrganization,WindowsRegisteredOrganization,WindowsRegisteredOwner,
    OsName,OSDisplayVersion,WindowsSystemRoot,CsChassisBootupState,
    CsPowerSupplyState,CsThermalState,BiosListOfLanguages,
    BiosManufacturer,BiosName,BiosOtherTargetOS,BiosReleaseDate,
    CsManufacturer,CsModel,CsDNSHostName,BiosSeralNumber,CsName,OsInstallDate,
    WindowsInstallDateFromRegistry,CsNetworkAdapters

Get-WmiObject -Class Win32_Bios

Get-WmiObject Win32_videocontroller | select caption,Current*Resolution

Get-WmiObject Win32_DesktopMonitor

ipconfig /all

dsregcmd.exe /status

net user

net localgroup Users

net localgroup Guests

net localgroup

net localgroup Administrators

wmic product get Name,InstallDate,InstallLocation,Vendor

wmic startup get caption,command

Get-ScheduledTask | #where{
    #($_.Author -ne "Microsoft") -and     
    #($_.Author -ne "Microsoft Office") -and
    #($_.Author -ne "Microsoft Corporation.") -and 
    #($_.Author -ne "Microsoft Corporation") -and 
    #($_.Source -ne "Microsoft Corporation") -and
    #($_.URI -notlike "\Microsoft\Windows\*")} | 
    select TaskName,Author,State,URI | sort State,URI | ft

Get-WmiObject win32_process | select CommandLine,ProcessID

#Get-WmiObject -Class Win32_Service
Get-CimInstance -ClassName Win32_Service
Get-CimInstance -ClassName Win32_Service | Select Name,DisplayName,Status,State,StartMode,ServiceType,Caption,Description,PathName

Get-WmiObject -Class Win32_Process

Get-WmiObject -Namespace "root/default" -List | fl

Get-NetTCPConnection
Get-PSDrive

Get-NetUDPEndpoint -LocalPort 5353 | Select-Object LocalAddress,LocalPort,OwningProcess,@{ Name="ProcessName"; Expression={((Get-Process -Id $_.OwningProcess).Name )} }

Get-CimInstance -ClassName Win32_Desktop -Property *
Get-CimInstance -ClassName Win32_BIOS -Property *
Get-CimInstance -ClassName Win32_Processor -Property *
Get-CimInstance -ClassName Win32_ComputerSystem -Property *
Get-CimInstance -ClassName Win32_QuickFixEngineering -Property * | sort InstalledOn
Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property *user*
Get-CimInstance -ClassName Win32_OperatingSystem -Property *
Get-CimInstance -ClassName Win32_LogonSession
Get-CimInstance -ClassName Win32_LocalTime
Get-CimInstance -ClassName Win32_LogicalDisk
Get-CimInstance -ClassName Win32_DiskDrive | where{$_.InterfaceType -eq 'USB'}
Get-CimInstance -ClassName Win32_DiskDrive

Get-AppxPackage -AllUsers -Name Microsoft.MSPaint | Remove-AppxPackage -AllUsers
Get-AppxPackage -AllUsers -Name Microsoft.HEVCVideoExtension* | Remove-AppxPackage -AllUsers

wmic product where name="Google Chrome" call uninstall /nointeractive

$app = Get-WmiObject -Class Win32_Product -Filter "Name = '<PROGRAM NAME HERE>'"
$app.Uninstall()

C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -c "$($Results = Get-WmiObject win32_process | select ProcessID,CommandLine | where{($_.CommandLine -like '*chrome remote*') -and ($_.CommandLine -notlike '*WindowsPowerShell*')}; foreach($Result in $Results.ProcessID){taskkill /F /PID $Result})"

Get-ADDefaultDomainPasswordPolicy

```

#
---
#

<sub><sup>CyberCondor does not maintain the documentation for PowerShell nor CMD commands. <br>
Microsoft has wonderful documentation that you should consult for any questions about the commands listed here.</sup></sub><br>
<sub><sup>CyberCondor - 2023</sup></sub>
