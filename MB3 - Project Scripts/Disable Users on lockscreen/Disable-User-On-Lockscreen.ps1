#######################################################################
#                     Disable User List v1.0                          #  
#               By Felix Saville - On Behalf Of MB3                   #
#                       Date: 11/05/2022                              #
#                                                                     #
#     This tool will disable certain registry keys that affect        #
#     user login information, and will remove all recent users        #
#     on the user selection menu with a "Domain Login" screen.        # 
#                                                                     #
#     The tool will make all of the registry changes using            #
#     powershell, and hopefully allow for the intended result.        #
#                                                                     #
#     ***Note: This tool needs to be run as an Administrator***       #
#                                                                     #
#######################################################################

# Startup Items

Set-ExecutionPolicy Bypass

$ButtonType1 = [System.Windows.Forms.MessageBoxButtons]::OK

$MessageIcon1 = [System.Windows.Forms.MessageBoxIcon]::Information

$MessageBody1 = "Disbale User List Script Started, Please wait!"

$MessageTitle1 = "Disable User List Script"

[System.Windows.Forms.MessageBox]::Show($MessageBody1,$MessageTitle1,$ButtonType1,$MessageIcon1)

Write-Host "Script Starting..." -ForegroundColor Yellow
$ScriptVersion = "Disable_User_List_v1.0"

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
Disable user script (V1.0) written by Felix Saville.
Please contact the author if you have any questions or concerns.
Contact info: Felix Saville - Felix.Saville@mb3.nz
**For complete ChangeLog, please contact the author.**

Script version: $ScriptVersion
"

New-ItemProperty -Path $registryPath -Name $name -Value $value `

    -PropertyType DWORD -Force | Out-Null