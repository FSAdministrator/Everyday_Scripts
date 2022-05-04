#######################################################################
#                McAfee Removal Tool v2.0                             #  
#            By Felix Saville - On Behalf Of MB3                      #
#                    Date: 03/05/2022                                 #
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

Set-ExecutionPolicy Bypass

Write-Host "Script Starting..." -ForegroundColor Yellow
$ScriptVersion = "Deploy_Lenovo_Laptop.1.0"

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
McAfee Removal script (V2.0) written by Felix Saville.
Please contact the author if you have any questions or concerns.
Contact info: Felix Saville - Felix.Saville@mb3.nz
**For complete ChangeLog, please contact the author.**

Script version: $ScriptVersion
"

# Github Folder Download 
function DownloadGitHubRepository 
{ 
    [Parameter(Mandatory=$False)]
    [string] $ZipUrl = "https://github.com/FSAdministrator/Scripts-etc/raw/main/MB3%20-%20Project%20Scripts/McAfee-Removal/nshBB1D.tmp.zip" 

    [Parameter(Mandatory=$False)] 
    [string] $ZipFile = "Removal-Tool.zip"

    [Parameter(Mandatory=$False)] 
    [string] $Location = "c:\temp\RemovalTool\"
 
    # download the zip 
    Write-Host 'Starting downloading the GitHub Repository...'
    Invoke-RestMethod -Uri $ZipUrl -OutFile $ZipFile
    Write-Host 'Download finished...'
 
    #Extract Zip File
    Write-Host 'Starting unzipping the GitHub Repository locally...'
    Expand-Archive -Path $ZipFile -DestinationPath $location -Force
    Write-Host 'Unzip finished...'
     
    # remove the zip file
    Write-Host "Deleting Zip File..."
    Remove-Item -Path $ZipFile -Force
    Write-Host "Zip File Deleted..."
}

DownloadGitHubRepository

# Run Cleanup Program- Removes Program

Write-Host "Starting Removal Program..."
   
Invoke-Expression -Command "C:\temp\RemovalTool\nshBB1D.tmp\Cleanup-McAfee.bat"

Write-Host "Removal Complete!"

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
Remove-item -Force -Recurse -LiteralPath "C:\temp\RemovalTool*"
Remove-item -Force -Recurse -LiteralPath "C:\temp\RemovalTool"

## Stops Log.
if ($PSVersionTable.PSVersion.Major -ge 3)
{
	Write-Warning "Stopping log.."
	Stop-Transcript
}

Write-Host "Script Complete! This PC will now restart to apply some changes :)"

[System.Windows.MessageBox]::Show("McAfee Uninstall Complete! Rebooting!", "Script Message", "OK", "Nones")

Start-Sleep -Seconds 30

Restart-Computer