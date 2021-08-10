#!/bin/bash

########################################################################
#                      Slack License Status - EA                       #
################### Written by Phil Walker Sep 2020 ####################
########################################################################

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "/Applications/Slack.app" ]]; then
    # Find if Slack is MAS or Standalone
    slackInstallType=$(mdls /Applications/Slack.app -name kMDItemAppStoreHasReceipt | awk '{print $3}')
    if [[ "$slackInstallType" == "1" ]]; then
        # Find if Slack is VPP licensed
        slackLicenseStatus=$(mdls /Applications/Slack.app -name kMDItemAppStoreReceiptIsVPPLicensed | awk '{print $3}')
        if [[ "$slackLicenseStatus" == "1" ]]; then
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