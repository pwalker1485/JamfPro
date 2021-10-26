#!/bin/zsh

########################################################################
#                    iCloud Account Status - EA                        #
################## Written by Phil Walker Oct 2021 #####################
########################################################################

#########################################################################
#								Variables								#
#########################################################################

# Plist buddy
plistBuddy="/usr/libexec/PlistBuddy"
# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -e "/Users/${loggedInUser}/Library/Preferences/MobileMeAccounts.plist" ]]; then
    useriCloudStatus=$("$plistBuddy" -c "print :Accounts:0:LoggedIn" "/Users/${loggedInUser}/Library/Preferences/MobileMeAccounts.plist" 2>/dev/null)
    if [[ "$useriCloudStatus" == "true" ]]; then
        iCloudStatus="Logged In"
    else
        iCloudStatus="Not Logged In"
    fi
else
    iCloudStatus="No Account Found"
fi
echo "<result>$iCloudStatus</result>"
exit 0