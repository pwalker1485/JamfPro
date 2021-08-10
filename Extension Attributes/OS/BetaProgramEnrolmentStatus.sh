#!/bin/zsh

########################################################################
#                 Beta Program Enrolment Status - EA                   #
################## Written by Phil Walker Nov 2020 #####################
########################################################################

# Beta Program Status
betaProgram=$(/System/Library/PrivateFrameworks/Seeding.framework/Resources/seedutil current | awk '/enrolled/{print $NF}')

if [[ "$betaProgram" == "(null)" ]]; then
    echo "<result>Not Enrolled</result>"
else
    echo "<result>$betaProgram</result>"
fi
exit 0