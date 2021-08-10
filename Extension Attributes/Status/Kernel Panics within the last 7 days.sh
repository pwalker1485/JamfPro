#!/bin/zsh

########################################################################
#              Kernel Panics within the last 7 days - EA               #
########################################################################
# Script made available by Rich Trouton on Git Hub
# https://github.com/rtrouton/rtrouton_scripts/blob/master/rtrouton_scripts/Casper_Extension_Attributes/kernel_panic_detection/kernel_panic_detection.sh
# Switched from bash to zsh

# Number of kernel panics within the last 7 days
panicLogCount=$(find /Library/Logs/DiagnosticReports -Btime -7 -name "*.panic" | grep . -c)
echo "<result>$panicLogCount</result>"