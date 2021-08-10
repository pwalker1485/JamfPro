#!/bin/bash

########################################################################
#                      Snow Agent Version - EA                         #
################### Written by Phil Walker Sep 2020 ####################
########################################################################

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -e "/opt/snow/snowagent" ]]; then
    # Check the version
    agentVersion=$(/opt/snow/snowagent version | cut -f1 -d"+")
    echo "<result>${agentVersion}</result>"
else
    echo "<result>Not Installed</result>"
fi
exit 0