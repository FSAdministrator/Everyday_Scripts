#######################################################################
#                McAfee Removal Tool v2.0                             #  
#                    By Felix Saville                                 #
#                                                                     #
#     This tool will stop all running McAfee Services and tasks,      #
#     seek out uninstall strings for associated McAfee Products,      #
#     And silently remove them.                                       # 
#                                                                     #
#     The tool will then remove all McAfee services and directories   #
#     from Program Files,  Program Files (x86), and ProgramData       #
#                                                                     #
# ***Note: This tool needs to be run as an Administrator              #
#                                                                     #
#######################################################################

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

MLSVer = Get-ChildItem -Path 

$app = Get-WmiObject -Class Win32_Product | Where-Object { 
    $_.Name -match "McAfee LiveSafe" 
}

$app.Uninstall()