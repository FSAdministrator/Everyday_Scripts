#!/bin/bash
################################################################################
#  ABOUT THIS SCRIPT
#
#  NAME
#    TeamViewerDeploy.sh
#
#  SYNOPSIS
#    ./TeamViewerDeploy.sh
#
#  DESCRIPTION
#    Downloads the latest TeamViewer Host package, effectively going to 
#    get.teamviewer.com/YOURCUSTOMHOSTURL in a browser.
#
#  DEPLOYED
#   OJC, IPU
#
################################################################################
# Downloads the latest TeamViewer Host package, effectively going to 
# get.teamviewer.com/YOURCUSTOMHOSTURL in a browser.

########################################################
LOGFILE="/Library/Logs/TeamViewerInstall.log"
DOWNLOADDIR="/Users/Shared"
# Ex. 12, 13, or 14
MAJORVERSION="15"
# Custom module ID, everything after the hyphen in the downloaded module
CUSTOMID="idc6ev4uh8"
PKG="Install TeamViewerHost-${CUSTOMID}.pkg"
URL='https://dl.tvcdn.de//download/version_15x/CustomDesign/Install%20TeamViewerHost-idc6ev4uh8.pkg'

# Create a function to echo output and write to a log file
writelog() {
	/bin/echo "${1}"	"${2}" "${3}" "${4}"
	/bin/echo $(date) "${1}"	"${2}" "${3}" "${4}" >> $LOGFILE
}
########################################################

# Check for TeamViewer.log
if [ -f "$LOGFILE" ]; then
    writelog "CHECK: TeamViewerInstall.log Present."
else
    /usr/bin/touch $LOGFILE
    writelog "CREATED: TeamViewerInstall.log"
    /bin/chmod 777 $LOGFILE
    if [ $? = 0 ]; then
        writelog "SUCCESSFUL: Set TeamViewerInstall.log Permissions."
    else
        writelog "FAILED: Set TeamViewerInstall.log Permissions."
    fi
fi

writelog "——- START ——-"

writelog "DOWNLOADING: TeamViewer Host PKG"
/usr/bin/curl -L https://dl.tvcdn.de//download/version_15x/CustomDesign/Install%20TeamViewerHost-idc6ev4uh8.pkg -o "$DOWNLOADDIR"/"$PKG"

if [ -f "$DOWNLOADDIR/$PKG" ]; then
    # Installs package
    writelog "INSTALLING: TeamViewer Host …"
    /usr/sbin/installer -pkg "$DOWNLOADDIR/$PKG" -target /
    if [ $? = 0 ]; then
        writelog "TeamViewerHost Install: Successful."
        
        writelog "DELETING: TeamViewer Host PKG …"
        /bin/rm "$DOWNLOADDIR/$PKG"

        if [ ! -f "$DOWNLOADDIR/$PKG" ]; then
            writelog "TeamViewerHost Install PKG Deletion: Successful."
        else
            writelog "TeamViewerHost Install PKG Deletion: Failed."
        fi
        
        writelog "Launching TeamViewer Host for the first time …"
        /usr/bin/open -a "TeamViewerHost"

        writelog "Script Complete: TeamViewer Host Installed!"
    else
        writelog "TeamViewerHost Install: Failed."
        exit 1
    fi
fi

writelog "——- DONE ——-"

exit
