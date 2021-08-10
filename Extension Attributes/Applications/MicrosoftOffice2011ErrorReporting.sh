#!/bin/bash

########################################################################
#             Microsoft Office 2011 Error Reporting - EA               #
################## Written by Phil Walker Aug 2020 #####################
########################################################################
# 32-bit applications below left behind by Office 2011 for Mac
# /Library/Application Support/Microsoft/MERP2.0/Microsoft Ship Asserts.app
# /Library/Application Support/Microsoft/MERP2.0/Microsoft Error Reporting.app

########################################################################
#                            Variables                                 #
########################################################################

legacyMERP="/Library/Application Support/Microsoft/MERP2.0"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$legacyMERP" ]]; then
    echo "<result>Installed</result>"
else
    echo "<result>Not Installed</result>"
fi
exit 0