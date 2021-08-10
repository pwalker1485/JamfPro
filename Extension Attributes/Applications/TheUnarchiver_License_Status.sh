#!/bin/zsh

########################################################################
#                 The Unarchiver License Status - EA                   #
################### Written by Phil Walker June 2021 ###################
########################################################################

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "/Applications/The Unarchiver.app" ]]; then
    # Find if The Unarchiver is MAS or Standalone
    unarchiverInstallType=$(mdls "/Applications/The Unarchiver.app" -name kMDItemAppStoreHasReceipt | awk '{print $3}')
    if [[ "$unarchiverInstallType" == "1" ]]; then
        # Find if The Unarchiver is VPP licensed
        unarchiverLicenseStatus=$(mdls "/Applications/The Unarchiver.app" -name kMDItemAppStoreReceiptIsVPPLicensed | awk '{print $3}')
        if [[ "$unarchiverLicenseStatus" == "1" ]]; then
            echo "<result>MAS VPP</result>"
        else
            echo "<result>MAS Personal</result>"
        fi
    else
        echo "<result>Standalone</result>"
    fi
else
    echo "<result>Not Installed</result>"
fi
exit 0