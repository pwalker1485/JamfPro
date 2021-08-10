#!/bin/zsh

########################################################################
#            Adobe Creative Cloud Desktop App Status - EA              #
################### written by Phil Walker Nov 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Creative Cloud app
desktopApp="/Applications/Utilities/Adobe Creative Cloud/ACC/Creative Cloud.app"
# Creative Cloud Uninstaller
desktopUninstaller="/Applications/Utilities/Adobe Creative Cloud/Utils/Creative Cloud Uninstaller.app"

########################################################################
#                         Script starts here                           #
########################################################################

installStatus="Not Installed"
if [[ -d "/Applications/Utilities/Adobe Creative Cloud" ]]; then
    if [[ -d "$desktopApp" && "$desktopUninstaller" ]]; then
        installStatus="Installed"
    else
        installStatus="Missing"
    fi
fi
echo "<result>${installStatus}</result>"