#!/bin/zsh

########################################################################
#                      Snow Agent Version - EA                         #
################### Written by Phil Walker Nov 2021 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Snow Agent
snowAgent="/opt/snow/snowagent"

########################################################################
#                         Script starts here                           #
########################################################################

agentVersion=""
# Check if the agent is installed
if [[ -f "$snowAgent" ]]; then
    # Check the version
    agentVersion=$("$snowAgent" version | cut -f1 -d"+")
fi
echo "<result>${agentVersion}</result>"
exit 0