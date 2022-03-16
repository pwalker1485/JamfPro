#!/bin/zsh

########################################################################
#                Kill All Adobe Processes and Services                 #
################### Written by Phil Walker Aug 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in"
else
    # Get all user Adobe Launch Agents PIDs
    userPIDs=$(su -l "$loggedInUser" -c "/bin/launchctl list | grep adobe" | awk '{print $1}')
    # Kill all processes
    if [[ "$userPIDs" != "" ]]; then
        while IFS= read -r line; do
            kill -9 "$line" 2>/dev/null
        done <<< "$userPIDs"
    fi
    # Bootout all user Adobe Launch Agents
    launchctl bootout gui/"$loggedInUserID" /Library/LaunchAgents/com.adobe.* 2>/dev/null
    # Bootout Adobe Launch Daemons
    launchctl bootout system /Library/LaunchDaemons/com.adobe.* 2>/dev/null
    pkill -9 "obe"
    sleep 5
    # Close any Adobe Crash Reporter windows (e.g. Bridge)
    pkill -9 "Crash Reporter"
fi
exit 0