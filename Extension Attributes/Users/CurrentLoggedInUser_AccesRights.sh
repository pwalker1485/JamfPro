#!/bin/zsh

########################################################################
#            Current Logged In User's Access Rights - EA               #
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
    if [[ $(dsmemberutil checkmembership -U "$loggedInUser" -G admin) != *not* ]]; then
        echo "<result>Admin User</result>"
    else
	    echo "<result>Standard User</result>"
    fi
fi
exit 0