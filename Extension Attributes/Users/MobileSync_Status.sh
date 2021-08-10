#!/bin/bash

########################################################################
#                       MobileSync Status - EA                         #
################## Written by Phil Walker July 2019 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the current user's home directory
userHomeDirectory=$(/usr/bin/dscl . -read /Users/"$loggedInUser" NFSHomeDirectory | awk '{print $2}')
# Check for a MobileSync backup directory
#mobileSync=$(ls "${userHomeDirectory}/Library/Application Support/" | grep "MobileSync")
mobileSync=$(ls "${userHomeDirectory}/Library/Application Support/MobileSync/Backup" | wc -l)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$mobileSync" -ge "1" ]]; then
    echo "<result>Backup Found</result>"
else
    echo "<result>No Backup</result>"
fi
exit 0
