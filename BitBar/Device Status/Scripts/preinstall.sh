#!/bin/zsh

########################################################################
#      Install Bauer Menu Bar Application (BitBar) - preinstall        #
################## Written by Phil Walker Nov 2020 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# Previous Launch Agent
legacyLaunchAgent="/Library/LaunchAgents/com.hostname.menubar.plist"
# Current Launch Agent
launchAgent="/Library/LaunchAgents/com.bauer.menubar.app.plist"

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

function launchAgentStatus ()
{
# Get the status of the Bauer Menu Bar Launch Agent (legacy and current)
currentStatus=$(runAsUser launchctl list | grep -i "menubar")
if [[ "$currentStatus" != "" ]]; then
    echo "Bauer Menu Bar Launch Agent still running, removal failed!"
else
    echo "Bauer Menu Bar Launch Agent removed"
fi
}

function removePreviousContent ()
{
# Remove the previous Launch Agent
if [[ -e "$legacyLaunchAgent" || -e "$launchAgent" ]]; then
    rm -f "$legacyLaunchAgent" 2>/dev/null
    rm -f "$launchAgent" 2>/dev/null
    if [[ ! -e "$legacyLaunchAgent" && ! -e "$launchAgent" ]]; then
        echo "Bauer Menu Bar app Launch Agent plist removed successfully"
    else
        echo "Failed to remove the previous Bauer Menu Bar Launch Agent plist"
        exit 1
    fi
else
    echo "Bauer Menu Bar Launch Agent plist not found"
fi
# Remove the content
if [[ -d "/Library/Application Support/JAMF/bitbar" ]]; then
    rm -rf "/Library/Application Support/JAMF/bitbar"
    if [[ ! -d "/Library/Application Support/JAMF/bitbar" ]]; then
        echo "BitBar application removed"
    else
        echo "Failed to remove the BitBar application"
        exit 1
    fi
else
    echo "BitBar application not found in JAMF folder"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; then
    echo "No user logged in"
    # Remove previous content
    removePreviousContent
else
    echo "${loggedInUser} currently logged in"
    # Remove the Launch Agent
    if [[ -e "$legacyLaunchAgent" || -e "$launchAgent" ]]; then
        echo "Removing the Bauer Menu Bar Launch Agent..."
        launchctl bootout gui/"$loggedInUserID" "$legacyLaunchAgent" 2>/dev/null
        launchctl bootout gui/"$loggedInUserID" "$launchAgent" 2>/dev/null
        sleep 2
        launchAgentStatus
    else
        echo "Bauer Menu Bar Launch Agent not found"
    fi
    # Kill the BitBar app
    bitbarDistro=$(pgrep "BitBarDistro")
    if [[ "$bitbarDistro" != "" ]]; then
        echo "Killing the BitBarDistro process..."
        while [[ "$bitbarDistro" != "" ]]; do
            killall -9 "BitBarDistro" 2>/dev/null
        sleep 2
        # re-populate variable
        bitbarDistro=$(pgrep "BitBarDistro")
        done
        echo "BitBarDistro killed"
    fi
    # Remove previous content
    removePreviousContent
fi
exit 0