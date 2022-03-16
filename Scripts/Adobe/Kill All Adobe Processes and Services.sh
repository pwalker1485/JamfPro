#!/bin/zsh

########################################################################
#                Kill All Adobe Processes and Services                 #
################### Written by Phil Walker Aug 2020 ####################
########################################################################
# Modified Mar 2022

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")

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

########################################################################
#                         Script starts here                           #
########################################################################

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
exit 0