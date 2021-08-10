#!/bin/zsh

########################################################################
#          Active version of Oracle Java Development Kit 8 - EA        #
################## Written by Phil Walker June 2019 ####################
########################################################################
# Edit Jan 2021

########################################################################
#                            Variables                                 #
########################################################################

jdkCheck=$(find /Library/Java/JavaVirtualMachines -iname "*jdk*" -maxdepth 1 | awk 'END {print NR}')

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$jdkCheck" -gt "0" ]]; then
    activeJDK=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
    if [[ "$activeJDK" =~ "1.8" ]]; then
        echo "<result>$activeJDK</result>"
    else
        echo "<result>Not Installed</result>"
    fi
else
    echo "<result>Not Installed</result>"
fi
exit 0