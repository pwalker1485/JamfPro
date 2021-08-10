#!/bin/bash

########################################################################
#     Wacom Tablet Version of Android File Transfer App Status - EA    #
################### Written by Phil Walker Aug 2020 ####################
########################################################################
# Old versions of Wacom Tablet drivers included an archive called      #
# aft.tar
# Once Android File Transfer is installed on the system this archive   #
# is unarchived. Version 1.0 of Android File Transfer in the available #
# in /Applications/Wacom Tablet.localized/                             #

if [[ -d "/Applications/Wacom Tablet.localized/Android File Transfer.app" ]]; then
    echo "<result>Installed</result>"
else
    echo "<result>Not Installed</result>"
fi