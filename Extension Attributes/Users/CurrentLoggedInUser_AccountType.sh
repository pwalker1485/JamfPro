#!/bin/zsh

########################################################################
#     Current Logged In User Account Type (Mobile or Local) - EA       #
################## Written by Phil Walker Oct 2019 #####################
########################################################################
# Modified: Phil Walker Oct 2021

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Mobile account check
mobileAccount=$(dscl . -read /Users/"$loggedInUser" OriginalNodeName 2>/dev/null)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "<result>Login Screen</result>"
else
    if [[ "$mobileAccount" == "" ]]; then
        echo "<result>Local</result>"
    else
        echo "<result>Mobile</result>"
    fi
fi
exit 0