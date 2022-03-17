#!/bin/zsh

########################################################################
# Adobe Creative Cloud Application Upgrade Policy Script - Preinstall  #
################### Written by Phil Walker Aug 2020 ####################
########################################################################
# Designed to be used with an Adobe CC app installation policy to upgrade
# an end users version of a CC app to the latest version.
# Must be set to run before the package install

# Modified Mar 2022

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# App sap code (https://helpx.adobe.com/enterprise/kb/apps-deployed-without-base-versions.html)
sapCode="$4"
# CC app name
appNameForRemoval="$5"
# Removal release years
releaseYearN2="$6" # N-2 release year
releaseYearPrevious="$7" # Previous/LTS release year
# base version (https://helpx.adobe.com/enterprise/kb/apps-deployed-without-base-versions.html)
baseVersionN2="$8" # N-2 release
baseVersionPrevious="$9" # Previous/LTS release
# CC App name for helper windows e.g. Adobe Photoshop 2022
appNameForInstall="${10}"
# jamfHelper timeout setting e.g 7200 for 2 hours
helperTimeout="${11}"
############ Vari#ables for Jamf Pro Parameters - End ###################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# path to binary
binaryPath="/Library/Application Support/Adobe/Adobe Desktop Common/HDBox/Setup"
# CPU Architecture
cpuArch=$(/usr/bin/arch)
if [[ "$cpuArch" == "arm64" ]]; then
    platformID="macOS (Apple Silicon)"
else
    platformID="osx10-64"
fi
# jamfHelper
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
helperHeading="     Upgrade to ${appNameForInstall}     "

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
fi
}

function jamfHelperConfirm ()
{
# Show a message via jamfHelper that the update is ready, this is after it has been deferred
"$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" -heading "$helperHeading" -alignHeading natural \
-description "To keep your Mac secure ${appNameForRemoval} will now be upgraded to the latest version (All previous versions will be removed).
For this to complete successfully all Adobe CC applications must be closed during the process.

Please save all of your work before clicking Upgrade" -timeout "$helperTimeout" -countdown -alignCountdown center -button1 "Upgrade" -defaultButton "1"
}

function jamfHelperCleanUp ()
{
# Download in progress helper window
"$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description "Closing all Adobe CC applications and uninstalling all legacy versions of ${appNameForRemoval}..." \
-alignDescription natural &
}

function jamfHelperDownloadInProgress ()
{
# Download in progress helper window
"$jamfHelper" -windowType utility -icon "$helperIconDownload" -title "$helperTitle" \
-heading "$helperHeading" -alignHeading natural -description "Downloading and Installing ${appNameForInstall}...

⚠️ Please do not open any Adobe CC app ⚠️

            ⏱ Download time will vary ⏱" -alignDescription natural &
}

function removePreviousVersions ()
{
echo "Uninstalling previous verisons of ${appNameForRemoval}..."
# Uninstall N-2 release
if [[ "$baseVersionN2" != "" ]]; then
    # If the app has no release year in the name (Dimension, XD etc) then report the base version after the uninstall
    if [[ "$releaseYearN2" == "" ]]; then
        releaseYearN2="$baseVersionN2"
    fi
    "$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion="$baseVersionN2" --platform="$platformID" --deleteUserPreferences=false &>/dev/null
    uninstallResultN2="$?"
    if [[ "$uninstallResultN2" -eq "0" ]]; then
        echo "${appNameForRemoval} ${releaseYearN2} uninstalled"
    fi
     # Confirm the directory has been deleted - manually installed plugins can result in the directory not being removed
    if [[ -d "/Applications/${appNameForRemoval} ${releaseYearN2}" ]]; then
        rm -rf "/Applications/${appNameForRemoval} ${releaseYearN2}" &>/dev/null
    fi
fi
# Uninstall previous release
if [[ "$baseVersionPrevious" != "" ]]; then
    # If the app has no release year in the name (Dimension, XD etc) then report the base version after the uninstall
    if [[ "$releaseYearPrevious" == "" ]]; then
        releaseYearPrevious="$baseVersionPrevious"
    fi
    "$binaryPath" --uninstall=1 --sapCode="$sapCode" --baseVersion="$baseVersionPrevious" --platform="$platformID" --deleteUserPreferences=false &>/dev/null
    uninstallResultPrevious="$?"
    if [[ "$uninstallResultPrevious" -eq "0" ]]; then
        echo "${appNameForRemoval} ${releaseYearPrevious} uninstalled"
    fi
    # Confirm the directory has been deleted - manually installed plugins can result in the directory not being removed
    if [[ -d "/Applications/${appNameForRemoval} ${releaseYearPrevious}" ]]; then
        rm -rf "/Applications/${appNameForRemoval} ${releaseYearPrevious}" &>/dev/null
    fi
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, starting upgrade..."
    # Remove all previous versions
    removePreviousVersions
else
    echo "jamfHelper displayed to ${loggedInUser} to start the upgrade process"
    # Advise the user what is happening and get confirmation or run anyway in 2 hours time
    jamfHelperConfirm
    # jamfHelper for app closure and removal
    jamfHelperCleanUp
    # Wait a few seconds for the helper message to be seen before closing the apps
    sleep 5
    # Kill processes to allow uninstall
    killAdobe
    # Wait before uninstalling
    sleep 10
    # Remove all previous versions
    removePreviousVersions
    # Kill the cleaning up helper
    killall -13 "jamfHelper" &>/dev/null
    # jamfHelper for app download+install
    jamfHelperDownloadInProgress
fi
exit 0