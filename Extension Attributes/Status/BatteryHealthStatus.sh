#!/bin/zsh

########################################################################
#                   Battery Health Status - EA                         #
################ Written by Phil Walker Sept 2021 ######################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the model
macModel=$(sysctl -n hw.model)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$macModel" =~ "MacBook" ]]; then
    batteryCondition=$(system_profiler SPPowerDataType | grep "Condition" | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//')
    echo "<result>$batteryCondition</result>"
else
    echo "<result>N/A</result>"
fi
exit 0