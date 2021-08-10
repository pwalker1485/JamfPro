#!/bin/bash

########################################################################
#          Logged in user account type (Mobile or Local) - EA          #
################## Written by Phil Walker Oct 2019 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the current logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Check if logged in user account is a mobile account
mobileAccount=$(dscl . -read /Users/"$loggedInUser" OriginalNodeName 2>/dev/null)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "<result>No logged in user</result>"
else
    if [[ "$mobileAccount" == "" ]]; then
        echo "<result>Local</result>"
    else
        echo "<result>Mobile</result>"
    fi
fi
exit 0