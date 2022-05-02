#######################################################################
#                McAfee Removal Tool v1.0                             #  
#                    By Felix Saville                                 #
#                                                                     #
#     This tool will stop all running McAfee Services and tasks,      #
#     seek out uninstall strings for associated McAfee Products,      #
#     And silently remove them.                                       # 
#                                                                     #
#     The tool will then remove all McAfee services and directories   #
#     from Program Files,  Program Files (x86), and ProgramData       #
#                                                                     #
#      ***Note: This tool needs to be run as an Administrator         #
#                                                                     #
#######################################################################

# Startup Items

Write-Host "Script Starting..." -ForegroundColor Yellow
$ScriptVersion = "Deploy_Lenovo_Laptop.1.0"
set-executionpolicy unrestricted

Write-Host "Checking OS version..." -ForegroundColor Yellow
If ((Get-WmiObject Win32_OperatingSystem).Caption -like '*server*')
{
	Write-Warning "This script is not designed to run on a Server OS. The script will now close."
	## Removing all script files for security reasons.
	Write-Warning "Removing script files for security purposes..."
	## Self destructs script.
	Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force
	Write-Host "File deletion completed" -ForegroundColor Green
	Write-Warning "Press any key to exit...";
	$x = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
}
else
{
	Write-Host "OS Version verified. Continuing..." -ForegroundColor Green
}

Write-Host "Checking for administrative rights..." -ForegroundColor Yellow
## Get the ID and security principal of the current user account.
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID);

## Get the security principal for the administrator role.
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;

## Check to see if we are currently running as an administrator.
if ($myWindowsPrincipal.IsInRole($adminRole))
{
	## We are running as an administrator, so change the title and background colour to indicate this.
	Write-Host "We are running as administrator, changing the title to indicate this." -ForegroundColor Green
	$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)";
}
else
{
	Write-Host "We are not running as administrator. Relaunching as administrator." -ForegroundColor Yellow
	## We are not running as admin, so relaunch as admin.
	$NewProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
	## Specify the current script path and name as a parameter with added scope and support for scripts with spaces in it's path.
	$NewProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
	## Indicate that the process should be elevated.
	$NewProcess.Verb = "runas";
	## Start the new process
	[System.Diagnostics.Process]::Start($newProcess);
	## Exit from the current, unelevated, process.
	Exit;
}

Write-Host "Continuing with setup..." -ForegroundColor Yellow

## Start log.
if ($PSVersionTable.PSVersion.Major -ge 3)
{
	Write-Host "We are running Powershell version 3 or greater. Logging enabled." -ForegroundColor Green
	If ((Test-Path C:\Logs\) -eq $false)
	{
		New-Item C:\Logs\ -ItemType Directory
	}
	Start-Transcript -Path "C:\Logs\$ScriptVersion.$(Get-Date -UFormat %Y%m%d).log"
}

$INFO = "
Anti-Virus Removal script written by Felix Saville.
Please contact the author if you have any questions or concerns.
Contact info: Felix Saville - Felix.Saville@mb3.nz
**For complete ChangeLog, please contact the author.**

Script version: $ScriptVersion
"


# Stop All McAfee Services

Write-Host "Shutting Down McAfee Services..."

Stop-Service -Name "McAWFwk" -Force -Confirm:$false
Stop-Service -Name "McAPExe" -Force -Confirm:$false
Stop-Service -Name "0108521651448370mcinstcleanup" -Force -Confirm:$false
Stop-Service -Name "mccspsvc" -Force -Confirm:$false
Stop-Service -Name "mfefire" -Force -Confirm:$false
Stop-Service -Name "ModuleCoreService" -Force -Confirm:$false
Stop-Service -Name "PEFService" -Force -Confirm:$false
Stop-Service -Name "Mfemms" -Force -Confirm:$false
Stop-Service -Name "mfevtp" -Force -Confirm:$false
Stop-Service -Name "McAfee WebAdvisor" -Force -Confirm:$false

# Kill all McAfee Service Programs

Stop-Process -Name "ModuleCoreService" -Force -Confirm:$false
Stop-Process -Name "MMSSHOST" -Force -Confirm:$false
Stop-Process -Name "PEFService" -Force -Confirm:$false
Stop-Process -Name "MfeAVSvc" -Force -Confirm:$false
Stop-Process -Name "mfevtps" -Force -Confirm:$false
Stop-Process -Name "mcsheild" -Force -Confirm:$false
Stop-Process -Name "McVulCtr" -Force -Confirm:$false
Stop-Process -Name "McUICnt" -Force -Confirm:$false
Stop-Process -Name "mfemms" -Force -Confirm:$false
Stop-Process -Name "ProtectedModuleHost" -Force -Confirm:$false
Stop-Process -Name "mcapexe" -Force -Confirm:$false

# Uninstall McAfee 

Write-Host "Completing McAfee Uninstall..."

& "C:\Program Files\McAfee\MSC\mcuihost.exe" /body:misp://MSCJsRes.dll::uninstall.html /id:uninstall /Silent | Out-Null


# File Directory Cleanup

Write-host "Deleting Folders For McAfee..."

Remove-Item -Force -Recurse -LiteralPath "C:\Program Files\McAfee*"
Remove-Item -Force -Recurse -LiteralPath "C:\Program Files\McAfee"
Remove-Item -Force -Recurse -LiteralPath "C:\Program Files\McAfee.com*"
Remove-Item -Force -Recurse -LiteralPath "C:\Program Files\McAfee.com"
Remove-Item -Force -Recurse -LiteralPath "C:\Program Files\Common Files\McAfee*"
Remove-Item -Force -Recurse -LiteralPath "C:\Program Files\Common Files\McAfee"
Remove-Item -Force -Recurse -LiteralPath "C:\Program Files (X86)\McAfee*"
Remove-Item -Force -Recurse -LiteralPath "C:\Program Files (X86)\McAfee"

# McAfee Services Removal

Write-Host "Removing McAfee Services from device..."

sc.exe delete "McAffee Activation Service"
sc.exe delete "McAfee AP Service"
sc.exe delete "McAfee Application Installer Cleanup (0108521651448370)"
sc.exe delete "McAfee CSP Service"
sc.exe delete "McAfee Firewall Core Service"
sc.exe delete "McAfee Module Core Service"
sc.exe delete "McAfee PEF Service"
sc.exe delete "McAfee Service Controller"
sc.exe delete "McAfee Validatoon Trust Protection Service"
sc.exe delete "McAfee WebAdvisor"

Write-Host "Script Complete, Restarting Device..."

## Stops Log.
if ($PSVersionTable.PSVersion.Major -ge 3)
{
	Write-Warning "Stopping log.."
	Stop-Transcript
}

Start-Sleep -Seconds 30

#Restart-Computer



# Redundant Code (DO NOT USE!)

#$app = Get-WmiObject -Class Win32_Product | Where-Object { 
#    $_.Name -match "McAfee LiveSafe" 
#}
#$app.Uninstall()