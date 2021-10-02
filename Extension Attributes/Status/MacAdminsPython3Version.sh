#!/bin/zsh

########################################################################
#                   MacAdmins Python 3 Version - EA                    #
################### written by Phil Walker Sept 2021 ###################
########################################################################
# (https://github.com/macadmins/python)

########################################################################
#                            Variables                                 #
########################################################################

# MacAdmins Python 3
macadminsPython="/Library/ManagedFrameworks/Python/Python3.framework"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -d "$macadminsPython" ]]; then
    pythonVersion=$("${macadminsPython}/Versions/Current/bin/python3" --version | awk '{print $2}')
    if [[ "$pythonVersion" != "" ]]; then
        pythonStatus="$pythonVersion"
    else
        pythonStatus="Not Installed"
    fi
else
    pythonStatus="Not Installed"
fi
echo "<result>$pythonStatus</result>"
exit 0