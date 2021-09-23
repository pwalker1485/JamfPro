#!/bin/zsh

########################################################################
#                      macOS Upgrade Status - EA                       #
################## Written by Phil Walker Sept 2019 ####################
########################################################################
# Last Modified Sept 2021

########################################################################
#                            Variables                                 #
########################################################################

# Installer location
macOSInstaller="/Applications/Install macOS Big Sur.app"
# Required disk space
requiredSpace="36"
# Target OS version
targetOS="11"
# OS Version
osVersion=$(sw_vers -productVersion)

########################################################################
#                         Script starts here                           #
########################################################################

# Get available disk space
freeSpace=$(diskutil info / | grep "Free Space" | awk '{print $4}')
freeSpaceFull=$(diskutil info / | grep "Free Space" | awk '{print $4, $5}')
if [[ -z "$freeSpace" ]]; then
	freeSpace="5"
fi
# Confirm there is enough disk space for the upgrade
if [[ ${freeSpace%.*} -ge ${requiredSpace} ]]; then
	spaceStatus="OK"
fi
# Confirm the installer is available
if [[ -d "$macOSInstaller" ]]; then
	installerStatus="Found"
else
	installerStatus="Not Found"
fi
# Upgrade Status
autoload is-at-least
if ! is-at-least "$targetOS" "$osVersion"; then
	if [[ "$spaceStatus" == "OK" ]] && [[ "$installerStatus" == "Found" ]]; then
      	echo "<result>Upgrade Ready</result>"
    else
      	echo "<result>Disk space: ${freeSpaceFull} | Installer: ${installerStatus}</result>"
	fi
else
	echo "<result>Not Required</result>"
fi
exit 0