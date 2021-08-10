#!/bin/zsh

########################################################################
#                      macOS Upgrade Status - EA                       #
################## Written by Phil Walker Sept 2019 ####################
########################################################################
# Modified June 2020
# Modified Sep 2020
# Modified Oct 2020
# Modified June 2021

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Check the logged in user has a local account (for 10.12 MacBooks only)
mobileAccount=$(dscl . -read /Users/"$loggedInUser" OriginalNodeName 2>/dev/null)
# Path to Jamf Connect Login bundle
jclBundle="/Library/Security/SecurityAgentPlugins/JamfConnectLogin.bundle"
# Installer location
macOSInstaller="/Applications/Install macOS Catalina.app"
# Required disk space
requiredSpace="15"
# Target OS version
targetOS="10.15"
# OS Version
osVersion=$(/usr/bin/sw_vers -productVersion)

########################################################################
#                         Script starts here                           #
########################################################################

# Get available disk space
freeSpace=$(/usr/sbin/diskutil info / | grep "Free Space" | awk '{print $4}')
if [[ -z "$freeSpace" ]]; then
	freeSpace="5"
fi
# Confirm there is enough disk space for the upgrade
if [[ ${freeSpace%.*} -ge ${requiredSpace} ]]; then
	spaceStatus="OK"
fi
# Confirm the installer is available
if [[ -d "$macOSInstaller" ]]; then
	catalinaInstaller="Found"
else
	catalinaInstaller="Not Found"
fi
# Get account status of logged in user (Local or Mobile)
if [[ "$mobileAccount" == "" ]]; then
	accountStatus="Local"
else
	accountStatus="Mobile"
fi
# Upgrade Status
autoload is-at-least
if ! is-at-least "$targetOS" "$osVersion"; then
	if [[ -d "$jclBundle" ]] && [[ "$accountStatus" == "Local" ]]; then
		if [[ "$spaceStatus" == "OK" ]] && [[ "$catalinaInstaller" == "Found" ]]; then
      		echo "<result>Upgrade Ready</result>"
    	else
      		echo "<result>Disk space:${freeSpace}GB | Installer:${catalinaInstaller} | Account status:${accountStatus}</result>"
		fi
	else
  		echo "<result>Disk space:${freeSpace}GB | Installer:${catalinaInstaller} | Account status:${accountStatus}</result>"
	fi
else
	echo "<result>Not Required</result>"
fi
exit 0