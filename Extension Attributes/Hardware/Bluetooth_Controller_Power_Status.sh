#!/bin/zsh

########################################################################
#                 Bluetooth Controller Power State                     #
################## Written by Phil Walker July 2019 ####################
########################################################################
# Edit Jan 2022

# Load is-at-least
autoload is-at-least
########################################################################
#                            Variables                                 #
########################################################################

# OS product version
osVersion=$(sw_vers -productVersion)
# Monterey major version
montereyMajor="12"

########################################################################
#                         Script starts here                           #
########################################################################

if is-at-least "$montereyMajor" "$osVersion"; then
    btPowerState=$(system_profiler SPBluetoothDataType | awk '/State/ {print $NF}')
else
    controllerPowerState=$(/usr/libexec/PlistBuddy -c "print ControllerPowerState" /Library/Preferences/com.apple.Bluetooth.plist 2>/dev/null)
    if [[ "$controllerPowerState" == "1" ]] || [[ "$controllerPowerState" == "true" ]]; then
        btPowerState="On"
    else
        btPowerState="Off"
    fi
fi
echo "<result>${btPowerState}</result>"
exit 0