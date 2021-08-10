#!/bin/zsh

########################################################################
#                 Bootstrap Token Escrow Status - EA                   #
################### written by Phil Walker Nov 2020 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# OS Version Full and Short
osVersion=$(sw_vers -productVersion)
# macOS Catalina version number
catalinaOS="10.15"
# load is-at-least
autoload is-at-least

########################################################################
#                         Script starts here                           #
########################################################################

if is-at-least "$catalinaOS" "$osVersion"; then
	bootstrapToken=$(profiles status -type bootstraptoken | awk '/escrowed/{print $7}')
	if [[ "$bootstrapToken" == "YES" ]]; then
		tokenStatus="Escrowed"
	else
		tokenStatus="Not Escrowed"
	fi
else
	tokenStatus="OS Not Supported"
fi
echo "<result>$tokenStatus</result>"
exit 0