#!/bin/zsh

########################################################################
#       iCloud Drive Desktop and Documents Sync Status - EA            #
################## Written by Phil Walker Nov 2020 #####################
########################################################################

#########################################################################
#								Variables								#
#########################################################################

# Path to PlistBuddy
plistBuddy="/usr/libexec/PlistBuddy"
# Determine logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Variable to determine major OS version
osVersion=$(/usr/bin/sw_vers -productVersion)
# Big Sur (Additional keys added)
bigSur="11"

########################################################################
#                         Script starts here                           #
########################################################################

# Load is-at-least
autoload is-at-least
# Determine whether user is logged into iCloud
if [[ -e "/Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist" ]]; then
	iCloudStatus=$("$plistBuddy" -c "print :Accounts:0:LoggedIn" "/Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist" 2>/dev/null)
	if [[ "$iCloudStatus" == "true" ]]; then
        # Determine if the OS version is Big Sur or later (Big Sur does not have the Enabled keys)
        if is-at-least "$bigSur" "$osVersion"; then
            desktopStatus=$("$plistBuddy" -c "print :Accounts:0:Services:2:iCloudHomeDesktopEnabled:iCloudHomeDesktopEnabled:" "/Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist" 2>/dev/null)
            documentStatus=$("$plistBuddy" -c "print :Accounts:0:Services:2:iCloudHomeDocumentsEnabled:iCloudHomeDocumentsEnabled:" "/Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist" 2>/dev/null)
            if [[ "$desktopStatus" == "true" || "$documentStatus" == "true" ]]; then
                docSyncStatus="iCloud Account Enabled, Desktop/Document Sync Enabled"
            else
                docSyncStatus="iCloud Account Enabled"
            fi
        else
            # Determine whether user has enabled Drive enabled. Value should be either "true" or "false"
			driveStatus=$("$plistBuddy" -c "print :Accounts:0:Services:2:Enabled" "/Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist" 2>/dev/null)
            if [[ "$driveStatus" == "true" ]]; then
                desktopStatus=$("$plistBuddy" -c "print :Accounts:0:Services:2:iCloudHomeDesktopEnabled:iCloudHomeDesktopEnabled:" "/Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist" 2>/dev/null)
                documentStatus=$("$plistBuddy" -c "print :Accounts:0:Services:2:iCloudHomeDocumentsEnabled:iCloudHomeDocumentsEnabled:" "/Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist" 2>/dev/null)
                if [[ "$desktopStatus" == "true" || "$documentStatus" == "true" ]]; then
                    docSyncStatus="iCloud Account Enabled, Drive Enabled, Desktop/Document Sync Enabled"
                else
                    docSyncStatus="iCloud Account Enabled, Drive Enabled"
                fi
            else
				docSyncStatus="iCloud Account Enabled, Drive Not Enabled"
			fi
        fi
	else
		docSyncStatus="iCloud Account Disabled"
	fi
else
	docSyncStatus="iCloud Account Disabled"
fi
echo "<result>$docSyncStatus</result>"