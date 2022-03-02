#!/bin/zsh

########################################################################
#                     Rosetta 2 Install Status - EA                    #
#################### Written by Phil Walker Dec 2020 ###################
########################################################################
# Edit Aug 2021

########################################################################
#                            Variables                                 #
########################################################################

# CPU Architecture
cpuArch=$(/usr/bin/arch)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$cpuArch" == "arm64" ]]; then
    arch -x86_64 /usr/bin/true 2>/dev/null
    commandResult="$?"
    if [[ "$commandResult" -eq "1" ]]; then
        rosettaStatus="Not Installed"
    else
        rosettaStatus="Installed"
    fi
else
    rosettaStatus="Not Required"
fi
echo "<result>${rosettaStatus}</result>"
exit 0