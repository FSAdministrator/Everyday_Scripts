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

# Stop All McAfee Services

Stop-Service -Name "McAffee Activation Service" -Force
Stop-Service -Name "McAfee AP Service" -Force
Stop-Service -Name "McAfee Application Installer Cleanup (0108521651448370)" -Force
Stop-Service -Name "McAfee CSP Service" -Force
Stop-Service -Name "McAfee Firewall Core Service" -Force
Stop-Service -Name "McAfee Module Core Service" -Force
Stop-Service -Name "McAfee PEF Service" -Force
Stop-Service -Name "McAfee Service Controller" -Force
Stop-Service -Name "McAfee Validatoon Trust Protection Service" -Force
Stop-Service -Name "McAfee WebAdvisor" -Force

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

# Redundant Code (DO NOT USE!)

#$app = Get-WmiObject -Class Win32_Product | Where-Object { 
#    $_.Name -match "McAfee LiveSafe" 
#}
#$app.Uninstall()