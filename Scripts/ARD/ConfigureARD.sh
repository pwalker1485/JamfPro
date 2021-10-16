#!/bin/zsh

########################################################################
#                           Configure ARD                              #
################### Written by Phil Walker Dec 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# ARD Kickstart
ardKickstart="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"

########################################################################
#                         Script starts here                           #
########################################################################

echo "Configuring ARD..."
# Activate and enable for specified users only
"$ardKickstart" -activate -configure -allowAccessFor -specifiedUsers &>/dev/null
# Enable for username1 and username2 and give them all privs
"$ardKickstart" -configure -access -on -privs -all -users username1,username2 &>/dev/null
# Enable the menubar icon so users can see if they are being controlled
"$ardKickstart" -configure -clientopts -setmenuextra -menuextra yes &>/dev/null
# Restart the client to ensure that all config changes are in place
"$ardKickstart" -restart -agent -console -menu &>/dev/null
# Check changes
ardConfigForAdmin=$(dscl . -list /Users naprivs | awk '{print $1}' | grep "username1")
if [[ "$ardConfigForAdmin" == "username1" ]]; then
    echo "ARD configured successfully"
else
    echo "Failed to configure ARD for username1!"
fi
exit 0