#!/bin/zsh

########################################################################
#        Jamf Recurring Check-In Launch Daemon Status - EA             #
################## Written by Phil Walker Feb 2021 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Check if the Jamf Recurring Check-In Launch Daemon is permanently disabled
launchDaemonCheck=$(defaults read /var/db/com.apple.xpc.launchd/disabled.plist | grep "= 1" | grep "com.jamfsoftware.task.Every 30 Minutes") # On-Prem JSS
#launchDaemonCheck=$(defaults read /var/db/com.apple.xpc.launchd/disabled.plist | grep "= 1" | grep "com.jamfsoftware.task.Every 15 Minutes") # Cloud JSS

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$launchDaemonCheck" != "" ]]; then
    echo "<result>Disabled</result>"
else
    echo "<result>Enabled</result>"
fi
exit 0