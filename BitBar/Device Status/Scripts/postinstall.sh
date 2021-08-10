#!/bin/zsh

########################################################################
#      Install Bauer Menu Bar Application (BitBar) - postinstall       #
################## Written by Phil Walker Nov 2020 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
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
# Get the status of the Bauer Menu Bar Launch Agent
currentStatus=$(runAsUser launchctl list | grep "com.bauer.menubar.app" | awk '{print $3}')
if [[ "$currentStatus" != "" ]]; then
    echo "Bauer Menu Bar Launch Agent running"
else
    echo "Bauer Menu Bar Launch Agent not running!"
    echo "The app should launch after the next user login"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; then
    echo "No user logged in, nothing to do"
else
    echo "${loggedInUser} logged in, bootstrapping the Launch Agent..."
    # Bootstrap the Launch Agent
    launchctl bootstrap gui/"$loggedInUserID" "$launchAgent"
    sleep 2
    # Check the Launch Agent is now running
    launchAgentStatus
fi
exit 0