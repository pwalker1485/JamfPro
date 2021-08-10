#!/bin/zsh

########################################################################
#                      Xcode License Status - EA                       #
################### Written by Phil Walker Feb 2021 ####################
########################################################################

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "/Applications/Xcode.app" ]]; then
    # Find if Xcode is MAS or Standalone
    xcodeInstallType=$(mdls /Applications/Xcode.app -name kMDItemAppStoreHasReceipt | awk '{print $3}')
    if [[ "$xcodeInstallType" == "1" ]]; then
        # Find if Xcode is VPP licensed
        xcodeLicenseStatus=$(mdls /Applications/Xcode.app -name kMDItemAppStoreReceiptIsVPPLicensed | awk '{print $3}')
        if [[ "$xcodeLicenseStatus" == "1" ]]; then
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