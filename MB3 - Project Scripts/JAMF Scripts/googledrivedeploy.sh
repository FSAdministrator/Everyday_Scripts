#!/bin/sh
################################################################################
#  ABOUT THIS SCRIPT
#
#  NAME
#    InstallGoogleFileStream.sh
#
#  SYNOPSIS
#    ./InstallGoogleFileStream.sh
#
#  DESCRIPTION
#    Downloads latest version of File Stream from Google's servers and installs
#    it for the current user. If Google Drive is detected, the application is
#    stopped and deleted, but user data is not. If data is found, a
#    notification is displayed through JAMF helper.
#
#  DEPLOYED
#   OJC, IPU
#
################################################################################
# Set some Variables
SupportContactInfo="your system administrator."
dmgfile="GoogleDrive.dmg"
logfile="/Library/Logs/GoogleFileStreamInstallScript.log"
url="https://dl.google.com/drive-file-stream/GoogleDriveFileStream.dmg"
user=`ls -l /dev/console | cut -d " " -f 4`

# Say what we are doing
/bin/echo "`date`: Installing latest version of File Stream for $user..." >> ${logfile}

# Download All the Things
/bin/echo "`date`: Downloading the latest version of File Stream from Google's servers" >> ${logfile}
/usr/bin/curl -k -o /tmp/$dmgfile $url
/bin/echo "`date`: Mounting dmg file." >> ${logfile}
/usr/bin/hdiutil attach /tmp/$dmgfile -nobrowse -quiet

# Install the things. 
/bin/echo "`date`: Installing pkg" >> ${logfile}
/usr/sbin/installer -pkg /Volumes/Install\ Google\ Drive/GoogleDrive.pkg -target /

# Cleanup Tasks
/bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep "Install Google Drive" | awk '{print $1}') -quiet
/bin/echo "`date`: Deleting temp files." >> ${logfile}
rm -fv /tmp/$dmgfile
/bin/sleep 3
/bin/echo "`date`: Launching File Stream" >> ${logfile}
open -a /Applications/Google\ Drive.app/
/bin/echo "`date`: Finished." >> ${logfile}

exit 0
