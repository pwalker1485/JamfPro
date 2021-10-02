#!/bin/zsh

########################################################################
#                      Login Window Settings - EA                      #
################### Written by Phil Walker Sept 2021 ###################
########################################################################
# Required to report on the status for Apple Silicon Macs only

########################################################################
#                            Variables                                 #
########################################################################

# CPU Architecture
cpuArch=$(/usr/bin/arch)
# Plist buddy
plistBuddy="/usr/libexec/PlistBuddy"
# Login window preference plist
lwPrefs="/Library/Preferences/com.apple.loginwindow.plist"

########################################################################
#                         Script starts here                           #
########################################################################

# Make sure changes are only made on ARM CPU hardware
if [[ "$cpuArch" == "arm64" ]]; then
    echo "Apple Silicon chip detected, checking the loginwindow preferences..."
    showfullnameStatus=$("$plistBuddy" -c "print :SHOWFULLNAME" "$lwPrefs" 2>/dev/null)
    if [[ "$showfullnameStatus" == "false" ]]; then
        result="List of users"
    elif [[ "$showfullnameStatus" == "true" ]]; then
        result="Name and password"
    else
        result="Not Set"
    fi
else
    echo "Intel chip detected, nothing to check"
    result="N/A"
fi
echo "<result>$result</result>"
exit 0