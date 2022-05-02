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
#       ***Note: This tool needs to be run as an Administrator        #
#                                                                     #
#######################################################################

# Script Setup Config

Write-Host "Setting up..." -ForegroundColor Yellow
$ScriptVersion = "McAfee Removal Tool v1.0"

Write-Host "Checking OS version..." -ForegroundColor Yellow
    If ((Get-WmiObject Win32_OperatingSystem).Caption -like '*server*')
        {
        	Write-Warning "This script is not designed to run on a Server OS. The script will now close."
        	### Removing all script files for security reasons.
        	Write-Warning "Removing script files for security purposes..."
        	### Self destructs script.
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

### Get the ID and security principal of the current user account.
        $myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
        $myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID);

### Get the security principal for the administrator role.
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;

### Check to see if we are currently running as an administrator.
    if ($myWindowsPrincipal.IsInRole($adminRole))
        {
### We are running as an administrator, so change the title and background colour to indicate this.
        	Write-Host "We are running as administrator, changing the title to indicate this." -ForegroundColor Green
        	$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)";
    }
else
    {
	    Write-Host "We are not running as administrator. Relaunching as administrator." -ForegroundColor Yellow
### We are not running as admin, so relaunch as admin.
    	$NewProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
### Specify the current script path and name as a parameter with added scope and support for scripts with spaces in it's path.
	    $NewProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
### Indicate that the process should be elevated.
    	$NewProcess.Verb = "runas";
### Start the new process
	    [System.Diagnostics.Process]::Start($newProcess);
### Exit from the current, unelevated, process.
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

## Modules
if (Get-Module -ListAvailable -Name PackageManagement)
{
	
}
Else
{
	Install-PackageProvider -Name NuGet -Force
	Install-Module -Name PackageManagement -Force
}



# Stop All McAfee Services

net stop "McAffee Activation Service"
net stop "McAfee AP Service"
net stop "McAfee Application Installer Cleanup (0108521651448370)"
net stop "McAfee CSP Service"
net stop "McAfee Firewall Core Service"
net stop "McAfee Module Core Service"
net stop "McAfee PEF Service"
net stop "McAfee Service Controller"
net stop "McAfee Validatoon Trust Protection Service"
net stop "McAfee WebAdvisor"

# Kill all McAfee Service Programs

taskkill /f /im ModuleCoreService.exe
taskkill /f /im MMSSHOST.exe  
taskkill /f /im PEFService.exe 
taskkill /f /im MfeAVSvc.exe
taskkill /f /im mfevtps.exe
taskkill /f /im mcsheild.exe
taskkill /f /im McVulCtr.exe
taskkill /f /im McUICnt.exe
taskkill /f /im mfemms.exe
taskkill /f /im ProtectedModuleHost.exe
taskkill /f /im mcapexe.exe

# Uninstall McAfee Protection

Write-Host "Checking for McAfee software (Check 1)..." -ForegroundColor Yellow
if (($McAfeeSoftware) -ne $null)
{
	Write-Host "Found McAfee software..." -ForegroundColor Green
	foreach ($Software in @("McAfee Endpoint Security Adaptive Threat Prevention", "McAfee Endpoint Security Web Control",
			"McAfee Endpoint Security Threat Prevention", "McAfee Endpoint Security Firewall", "McAfee Endpoint Security Platform",
			"McAfee VirusScan Enterprise", "McAfee Agent"))
	{
		if ($McAfeeSoftware | Where-Object DisplayName -like $Software)
		{
			$McAfeeSoftware | Where-Object DisplayName -like $Software | ForEach-Object {
				Write-Host "Uninstalling $($_.DisplayName)"
				
				if ($_.uninstallstring -like "msiexec*")
				{
					Write-Debug "Uninstall string: Start-Process $($_.UninstallString.split(' ')[0]) -ArgumentList `"$($_.UninstallString.split(' ', 2)[1]) /qn REBOOT=SUPPRESS`" -Wait"
					Start-Process $_.UninstallString.split(" ")[0] -ArgumentList "$($_.UninstallString.split("  ", 2)[1]) /qn" -Wait
				}
				else
				{
					Write-Debug "Uninstall string: Start-Process $($_.UninstallString) -Wait"
					Start-Process $_.UninstallString -Wait
				}
			}
		}
	}
	Write-Host "Finished removing McAfee." -ForegroundColor Green
}
else
{
	Write-Host "McAfee software not found..." -ForegroundColor Yellow
	Write-Host "Continuing..." -ForegroundColor Green
}

## 20200716.x.Temporarily commenting out this portion of the removal.
Write-Host "Skipping McAfee Check 2..." -ForegroundColor Yellow

	## Removing Specific McAfee software.
Write-Host "Checking for McAfee (Check 2)..." -ForegroundColor Yellow
If ((WMIC product where "Name Like '%%McAfee%%'") -ne "No Instance(s) Available.")
{
	Write-Host "Removing McAfee VirusScan Enterprise..." -ForegroundColor Yellow
	WMIC product where "description= 'McAfee VirusScan Enterprise' " uninstall
	
	Write-Host "Removing McAfee Agent..." -ForegroundColor Yellow
	WMIC product where "description= 'McAfee Agent' " uninstall
}
else
{
	Write-Host "No removable McAfee software found..." -ForegroundColor Yellow
	Write-Host "Continuing..." -ForegroundColor Green
}

### Attempting to remove other McAfee software that isn't Tamper protected
Write-Host "Checking for McAfee (Check 3)..." -ForegroundColor Yellow
if ((Get-Package -Name McAfee*) -ne $null)
{
	Write-Host "Found McAfee Software..." -ForegroundColor Green
	Write-Host "Removing McAfee software..." -ForegroundColor Yellow
	Get-Package -Name McAfee* | Uninstall-Package -AllVersions -Force
	
}
else
{
	Write-Host "No removable McAfee software found..." -ForegroundColor Yellow
	Write-Host "Continuing..." -ForegroundColor Green
}

# File Directory Cleanup

Remove-Item -LiteralPath "C:\Program Files\McAfee*" -Force -Recurse
Remove-Item -LiteralPath "C:\Program Files\McAfee" -Force -Recurse 
Remove-Item -LiteralPath "C:\Program Files\McAfee.com*" -Force -Recurse
Remove-Item -LiteralPath "C:\Program Files\McAfee.com" -force -Recurse
Remove-Item -LiteralPath "C:\Program Files\Common Files\McAfee*" -Force -Recurse
Remove-Item -LiteralPath "C:\Program Files\Common Files\McAfee" -Force -Recurse
Remove-Item -LiteralPath "C:\Program Files (X86)\McAfee*" -Force -Recurse
Remove-Item -LiteralPath "C:\Program Files (X86)\McAfee" -Force -Recurse

# McAfee Services Removal

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


# Removing all script files for security reasons.
Write-Warning "Removing script files for security purposes..."
### Self destructs script.
Remove-Item -LiteralPath $MyInvocation.MyCommand.Path -Force
Remove-Item -Path "C:\Temp\mbstcmd.exe" -Force
Write-Host "File deletion completed" -ForegroundColor Green

# Stops Logging
if ($PSVersionTable.PSVersion.Major -ge 3)
{
	Write-Warning "Stopping log.."
	Stop-Transcript
}

# Redundant Code (DO NOT USE!)

#$app = Get-WmiObject -Class Win32_Product | Where-Object { 
#    $_.Name -match "McAfee LiveSafe" 
#}
#$app.Uninstall()