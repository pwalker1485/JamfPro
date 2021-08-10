#!/bin/zsh

########################################################################
#                        Outset Version - EA                           #
################### written by Phil Walker Nov 2020 ####################
########################################################################

outsetVersion="Not Installed"
if [[ -e "/usr/local/outset/outset" ]]; then
    # Check the version
    outsetVersion=$(/usr/local/outset/outset --version)
fi
echo "<result>${outsetVersion}</result>"