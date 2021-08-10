#!/bin/zsh

########################################################################
#              List All 32-bit Applications Installed - EA             #
######################## written by Phil Walker ########################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# OS Version
osVersion=$(sw_vers -productVersion)
# macOS Catalina version number
catalinaOS="10.15"
# Check for 32-bit Applications
# If running macOS Mojave or previous, exclude the system app InkServer.app and the system framework QuickLook which includes quicklookd32.app (both are 32-bit)
# Added additional exclusion for external disks for 10.14 as so many users have old crap on external disks
# Added additional exclusion for users OneDrive sync directory due to old crap having being uploaded to OneDrive
autoload is-at-least
if ! is-at-least "$catalinaOS" "$osVersion"; then
    thirtyTwoBitApps=$(/usr/bin/mdfind "kMDItemExecutableArchitectures == 'i386' && kMDItemExecutableArchitectures != 'x86_64' && \
kMDItemKind == 'Application'" | grep -v "/System/Library/Input Methods/InkServer.app" | grep -v "/System/Library/Frameworks/QuickLook.framework/Versions/A/Resources/quicklookd32.app" | \
grep -v "/Volumes" | grep -v "OneDrive - Bauer Media Group")
else
    thirtyTwoBitApps=$(/usr/bin/mdfind "kMDItemExecutableArchitectures == 'i386' && kMDItemExecutableArchitectures != 'x86_64' && kMDItemKind == 'Application'"  | \
grep -v "/Volumes" | grep -v "OneDrive - Bauer Media Group")
fi

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "${thirtyTwoBitApps}" != "" ]]; then
    echo "<result>${thirtyTwoBitApps}</result>"
else
    echo "<result>None Found</result>"
fi
exit 0