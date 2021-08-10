#!/bin/zsh

########################################################################
#              FileVault Encrypted PRK Backup Status - EA              #
################### Written by Phil Walker July 2021 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Encrypted PRK backup
prkBackup="/usr/local/BauerMediaGroup/FileVaultPRK/FileVaultPRK.dat"

########################################################################
#                         Script starts here                           #
########################################################################

if [[ -f "$prkBackup" ]]; then
    echo "<result>Found</result>"
else
    echo "<result>Not Found</result>"
fi
exit 0