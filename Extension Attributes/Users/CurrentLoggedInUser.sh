#!/bin/zsh

########################################################################
#                   Current Logged In User - EA                        #
########################################################################
# Modified: Phil Walker Oct 2021

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "root" ]] || [[ "$loggedInUser" == "" ]]; then
	echo "<result>Login Screen</result>"
else
	echo "<result>$loggedInUser</result>"
fi
exit 0