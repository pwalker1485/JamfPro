#!/bin/zsh

########################################################################
#           Open Skype for Business After User Login - EA              #
################### written by Phil Walker Jan 2021 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Launch Agent
launchAgent="/Library/LaunchAgents/com.bauer.OpenSkypeForBusinessAfterUserLogin.plist"
# Script
startupItem="/Library/StartupItems/OpenSkypeForBusinessAfterUserLogin.sh"

########################################################################
#                         Script starts here                           #
########################################################################

installStatus="Not Found"
if [[ -f "$launchAgent" || -f "$startupItem" ]]; then
    installStatus="Installed"
fi
echo "<result>${installStatus}</result>"