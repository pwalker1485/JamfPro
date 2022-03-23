#!/bin/bash

########################################################################
#         Adobe Acrobat DC Install Policy Script - Preinstall          #
################### Written by Phil Walker Aug 2020 ####################
########################################################################
# Must be set to run before the package install
# Process:
# Bootout Adobe Launch Agents/Daemons and kill all Adobe processes

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# CC App name for helper windows e.g. Adobe Acrobat DC
appNameForInstall="$4"
############ Variables for Jamf Pro Parameters - End ###################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# Jamf Helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
if [[ -d "/Applications/Utilities/Adobe Creative Cloud/Utils/Creative Cloud Uninstaller.app" ]]; then
    # Helper Icon Cloud Uninstaller
    helperIcon="/Applications/Utilities/Adobe Creative Cloud/Utils/Creative Cloud Uninstaller.app/Contents/Resources/CreativeCloudInstaller.icns"
else
    # helper Icon SS
    helperIcon="/Library/Application Support/JAMF/bin/Management Action.app/Contents/Resources/Self Service.icns"
fi
# Helper icon Download
installInProgress="/System/Library/CoreServices/Install in Progress.app/Contents/Resources"
if [[ -f "${installInProgress}/Installer.icns" ]]; then
    helperIconDownload="${installInProgress}/Installer.icns"
elif [[ -f "${installInProgress}/AppIcon.icns" ]]; then
    helperIconDownload="${installInProgress}/AppIcon.icns"
else
    helperIconDownload="/Library/Application Support/JAMF/bin/Management Action.app/Contents/Resources/Self Service.icns"
fi
# Helper title
helperTitle="Message from Department Name"
# Helper heading
helperHeading="          ${appNameForInstall}          "

########################################################################
#                            Functions                                 #
########################################################################

function runAsUser ()
{  
# Run commands as the logged in user
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, unable to run commands as a user"
else
    launchctl asuser "$loggedInUserID" sudo -u "$loggedInUser" "$@"
fi
}

function killAdobe ()
{
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in"
else
    # Get all user Adobe Launch Agents PIDs
    userPIDs=$(runAsUser launchctl list | grep "adobe" | awk '{print $1}')
    # Kill all processes
    if [[ "$userPIDs" != "" ]]; then
        while IFS= read -r line; do
            kill -9 "$line" &>/dev/null
        done <<< "$userPIDs"
    fi
    launchAgents=$(find "/Library/LaunchAgents" -iname "com.adobe*" -type f -maxdepth 1)
    if [[ "$launchAgents" != "" ]]; then
        # Bootout all user Adobe Launch Agents
        launchctl bootout gui/"$loggedInUserID" /Library/LaunchAgents/com.adobe.* &>/dev/null
    fi
    launchDaemons=$(find "/Library/LaunchDaemons" -iname "com.adobe*" -type f -maxdepth 1)
    if [[ "$launchDaemons" != "" ]]; then
        # Bootout Adobe Launch Daemons
        launchctl bootout system /Library/LaunchDaemons/com.adobe.* &>/dev/null
    fi
    pkill -9 "obe" &>/dev/null
    sleep 5
    # Close any Adobe Crash Reporter windows (e.g. Bridge)
    pkill -9 "Crash Reporter" &>/dev/null
    # Kill Safari processes - can cause install failure (Error DW046 - Conflicting processes are running)
    killall -9 "Safari" >/dev/null 2>&1
fi
}

function jamfHelperCleanUp ()
{
# Download in progress helper window
"$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description "Closing all Adobe CC applications and Safari..." -alignDescription natural &
}

function jamfHelperDownloadInProgress ()
{
# Download in progress helper window
"$jamfHelper" -windowType utility -icon "$helperIconDownload" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description "Downloading and Installing ${appNameForInstall}...

⚠️ Please do not open any Adobe CC app ⚠️

            ⏱ Download time will vary ⏱" -alignDescription natural &
}

########################################################################
#                         Script starts here                           #
########################################################################

# jamf Helper for killing apps and uninstalling previous versions
jamfHelperCleanUp
# Wait a few seconds for the helper message to be seen before closing the apps
sleep 5
# Kill processes to allow uninstall
killAdobe
# Wait before uninstalling
sleep 10
# Kill the cleaning up helper
killall -13 "jamfHelper" >/dev/null 2>&1
# Jamf Helper for app download+install
jamfHelperDownloadInProgress
exit 0