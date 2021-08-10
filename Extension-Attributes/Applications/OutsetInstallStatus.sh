#!/bin/zsh

########################################################################
#                     Outset Install Status - EA                       #
################### written by Phil Walker Nov 2020 ####################
########################################################################

installStatus="Not Installed"
if [[ -e "/usr/local/outset/outset" ]]; then
    installStatus="Installed"
fi
echo "<result>${installStatus}</result>"