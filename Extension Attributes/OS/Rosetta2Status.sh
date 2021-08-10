#!/bin/zsh

########################################################################
#                     Rosetta 2 Install Status - EA                    #
#################### Written by Phil Walker Dec 2020 ###################
########################################################################
# Edit July 2021

########################################################################
#                            Variables                                 #
########################################################################

# Intel CPU check
intelCPU=$(sysctl -n machdep.cpu.brand_string | grep -o "Intel")
# Rosetta 2 Launch Daemon (Pre 11.5)
launchDaemonOld="/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist"
# Rosetta 2 Launch Daemon
launchDaemon="/System/Library/LaunchDaemons/com.apple.oahd.plist"

########################################################################
#                         Script starts here                           #
########################################################################

# Check or an Intel CPU
if [[ -n "$intelCPU" ]]; then
    ### DEBUG
    #echo "Intel CPU detected, Rosetta 2 not required"
    rosettaStatus="Not Required"
else
    ### DEBUG
    #echo "Apple silicon Mac, checking Rosetta 2 install status"
    # Check for the Rosetta 2 Launch Daemon
    if [[ -f "$launchDaemon" ]] || [[ -f "$launchDaemonOld" ]]; then
        rosettaStatus="Installed"
    else
    	rosettaStatus="Not Installed"
    fi
fi
echo "<result>${rosettaStatus}</result>"
exit 0