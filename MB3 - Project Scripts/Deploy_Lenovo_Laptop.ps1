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

set-executionpolicy unrestricted

# Stop All McAfee Services

Stop-Service -Name "McAWFwk" -Force -Confirm
Stop-Service -Name "McAPExe" -Force -Confirm
Stop-Service -Name "0108521651448370mcinstcleanup" -Force -Confirm
Stop-Service -Name "mccspsvc" -Force -Confirm
Stop-Service -Name "mfefire" -Force -Confirm
Stop-Service -Name "ModuleCoreService" -Force -Confirm
Stop-Service -Name "PEFService" -Force -Confirm
Stop-Service -Name "Mfemms" -Force -Confirm
Stop-Service -Name "mfevtp" -Force -Confirm
Stop-Service -Name "McAfee WebAdvisor" -Force -Confirm

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

# Uninstall McAfee WebAdvisor Protection

$MWPVer = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Widnows\CurrentVersion\Uninstall |
    Get-ItemProperty |
        Where-Object {$_.DisplayName -match "WebAdvisor by McAfee" } |
            Select-Object -Property DisplayName, UninstallString

            ForEach ($ver in $MWPVer) {

                    If ($ver.UninstallString) {

                        $uninst = $ver.UninstallString
                            Start-Process cmd "/c $uninst /qn REBOOT=SUPRESS /PASSIVE" -NoNewWindow
                    }
                }

Start-Sleep -Seconds 30

# Uninstall Mcafee LiveSafe

MLSVer = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Widnows\CurrentVersion\Uninstall |
           Get-ItemProperty |
                Where-Object {$DisplayName -match "McAfee LiveSafe"} |
                    Select-Object -Property DisplayName, UninstallString

                    ForEach ($ver in $MLSVer) {

                        If ($ver.UninstallString) {
                            
                            $uninst = $ver.UninstallString
                                Start-Process cmd "/c $uninst /qn REBOOT=SUPRESS /PASSIVE" -NoNewWindow

                        }
                    }

Start-Sleep -Seconds 30

# McAfee Uninstall - Alternative 1

Write-Host "McAfee Uninstall - Alternative 1"

get-package -Name "McAfee Security" |% { & $_.Meta.Attributes["UninstallString"] }

# McAfee Uninstall - Alternative 2

Write-Host "McAfee Uninstall - Alternative 2"

Get-Package -Name 'McAfee Security' | Uninstall-Package -Force

# McAfee Uninstall - Alternative 3

Write-Host "McAfee Uninstall - Alternative 3"

& "C:\Program Files\McAfee\MSC\mcuihost.exe" /body:misp://MSCJsRes.dll::uninstall.html /id:uninstall /Silent | Out-Null

# McAfee Uninstall - Alternative 4

Write-Host "McAfee Uninstall - Alternative 4"

$McAfee = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "McAfee Security" }

$McAfee.Uninstall()

# McAfee Uninstall - Alternative 5

Write-Host "McAfee Uninstall - Alternative 5"

$uninstall32 = gci "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "McAfee Security" } | select UninstallString

$uninstall64 = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "McAfee Security" } | select UninstallString

 

if ($uninstall64) {

$uninstall64 = $uninstall64.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""

$uninstall64 = $uninstall64.Trim()

Write "Uninstalling..."

start-process "msiexec.exe" -arg "/X $uninstall64 /qb" -Wait}

if ($uninstall32) {

$uninstall32 = $uninstall32.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""

$uninstall32 = $uninstall32.Trim()

Write "Uninstalling..."

start-process "msiexec.exe" -arg "/X $uninstall32 /qb" -Wait}

# If All Else Fails

Start-Sleep -Seconds 60

Write-Host "Please Check Control Panel For Changes..."

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

Start-Sleep -Seconds 10

Write-Host "Script Complete, Restarting Device..."

#Restart-Computer

# Redundant Code (DO NOT USE!)

#$app = Get-WmiObject -Class Win32_Product | Where-Object { 
#    $_.Name -match "McAfee LiveSafe" 
#}
#$app.Uninstall()