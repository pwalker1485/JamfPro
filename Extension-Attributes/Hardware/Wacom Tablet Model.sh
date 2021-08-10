#!/bin/zsh

########################################################################
#                       Wacom Tablet Model - EA                        #
######################## written by Phil Walker ########################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Wacom tablet model
wacomTablet=$(ioreg -p IOUSB | grep -i "Intuos\|Cintiq\|MobileStudio\|ExpressKey\|CTL\|DTK\|DTH\|DTZ\|DTU\|DPM\|EKR\|PTH\|PTK" | sed 's/+-o//;s/|//g' | cut -f1 -d"<" -d"@" | sed 's/^ *//g')

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$wacomTablet" != "" ]]; then
    echo "<result>$wacomTablet</result>"
else
    echo "<result>No Wacom tablet is installed</result>"
fi
exit 0