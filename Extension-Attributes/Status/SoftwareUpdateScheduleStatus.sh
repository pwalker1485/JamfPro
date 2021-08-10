#!/bin/zsh

########################################################################
#                Software Update Schedule Status - EA                  #
######################## written by Phil Walker ########################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# OS Version
osVersion=$(sw_vers -productVersion)
# Minimum OS Version
minOS="10.13"
# Software Update 
suStatus=$(softwareupdate --schedule)

########################################################################
#                         Script starts here                           #
########################################################################

# Load is-at-least
autoload is-at-least
# If running macOS 10.13 or later then report the status
if is-at-least "$minOS" "$osVersion"; then
    echo "<result>$suStatus</result>"
else
    echo "<result>OS Not Supported</result>"
fi