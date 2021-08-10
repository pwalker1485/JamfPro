#!/bin/bash

#######################################################################
#                 Google Software Updater Status EA                   #
###################### written by Phil Walker #########################
#######################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
LoggedInUser=$(stat -f %Su /dev/console)
# Get the value of update interval check
GoogleUpdateInterval=$(su -l "$LoggedInUser" -c "defaults read com.google.Keystone.Agent checkInterval" 2>/dev/null)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$GoogleUpdateInterval" == "" ]]; then
    echo "<result>Google Software Updater Agent not running for $LoggedInUser</result>"
elif [[ "$GoogleUpdateInterval" == "0" ]]; then
    echo "<result>Interval check disabled for $LoggedInUser</result>"
else
    echo "<result>Interval check enabled for $LoggedInUser</result>"
fi
exit 0
