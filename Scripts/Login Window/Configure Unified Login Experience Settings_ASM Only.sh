#!/bin/zsh

########################################################################
#        Configure Unified Login Experience Settings (ASM Only)        #
################### Written by Phil Walker June 2021 ###################
########################################################################
# Set the unified login experience to a list of users.
# This keeps consistency with the look of the login window for both Apple Silicon and Intel Macs.

########################################################################
#                            Variables                                 #
########################################################################

# CPU Architecture
cpuArch=$(/usr/bin/arch)
# Plist buddy
plistBuddy="/usr/libexec/PlistBuddy"
# Login window preference plist
lwPrefs="/Library/Preferences/com.apple.loginwindow.plist"
# DEPNotify process
depNotify=$(pgrep "DEPNotify")

########################################################################
#                            Functions                                 #
########################################################################

depNotifyCheck ()
{
if [[ "$depNotify" != "" ]]; then
    echo "Mac is being provisioned, inventory will be updated after all policies have completed"
else
    echo "Updating inventory..."
    /usr/local/jamf/bin/jamf recon &>/dev/null
    echo "Inventory update sent to Jamf Pro"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Make sure changes are only made on ARM CPU hardware
if [[ "$cpuArch" == "arm64" ]]; then
    showfullnameStatus=$("$plistBuddy" -c "print :SHOWFULLNAME" "$lwPrefs" 2>/dev/null)
    if [[ "$showfullnameStatus" != "false" ]]; then
        echo "Apple Silicon chip detected, setting the loginwindow preferences..."
        defaults write "$lwPrefs" SHOWFULLNAME -bool false
        postCheck=$("$plistBuddy" -c "print :SHOWFULLNAME" "$lwPrefs")
        if [[ "$postCheck" == "false" ]]; then
            echo "loginwindow preferences set to 'List of users'"
            # Run an updatepreBoot command - without this the unified login window does not change
            diskutil quiet apfs updatepreBoot /
            # Check if an inventory update needs to be completed
            depNotifyCheck
        else
            echo "Failed to change loginwindow preferences"
            exit 1
        fi
    else
        echo "loginwindow preferences already set to 'List of users'"
        # Run an updatepreBoot command - Added as a precaution only if the settings are already correct
        diskutil quiet apfs updatepreBoot /
        # Check if an inventory update needs to be completed
        depNotifyCheck
    fi
else
    echo "Intel chip detected, nothing to do"
fi
exit 0