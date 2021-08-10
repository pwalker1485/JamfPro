#!/bin/bash

########################################################################
#              Bluetooth Controller Power Status - EA                  #
################## Written by Phil Walker July 2019 ####################
########################################################################

btPowerStatus=$(/usr/libexec/PlistBuddy -c "print ControllerPowerState" /Library/Preferences/com.apple.Bluetooth.plist)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$btPowerStatus" == "1" ]] || [[ "$btPowerStatus" == "true" ]]; then
    echo "<result>On</result>"
else
    echo "<result>Off</result>"
fi
exit 0
