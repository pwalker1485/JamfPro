#!/bin/bash

########################################################################
#                 FileVault Status (On or Off) - EA                    #
######################## written by Phil Walker ########################
########################################################################

fvStatus=$(fdesetup status | awk '/FileVault is/{print $3}' | tr -d .)
echo "<result>$fvStatus</result>"
exit 0