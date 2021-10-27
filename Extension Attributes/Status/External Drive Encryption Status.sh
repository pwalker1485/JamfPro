#!/bin/zsh

########################################################################
#               External Disks Encryption Status - EA                  #
################### written by Phil Walker Oct 2021 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Total external disks
externalDisks=$(diskutil list external | grep "physical" | awk 'END {print NR}')
# External disks device nodes
deviceNodes=$(df -hl | grep "/Volumes/" | grep -v "/System/Volumes" | awk '{print $1}')

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$externalDisks" -eq "0" ]]; then
    exit 0
else
    # Counter for encrypted external disks
    encryptedDisks="0"
    for disk in ${(f)deviceNodes}; do
        diskLocation=$(diskutil info "$disk" | grep "Device Location" | sed 's/Device Location://' | xargs)
        # Confirm disk is external
        if [[ "$diskLocation" == "External" ]]; then
            diskEncryption=$(diskutil info "$disk" | grep "FileVault" | sed 's/FileVault://' | xargs)
            if [[ "$diskEncryption" == "Yes" ]]; then
                encryptedDisks=$((encryptedDisks+1))
            fi
        fi
    done
    if [[ "$externalDisks" -eq "1" ]]; then
        echo "<result>${externalDisks} External Disk, ${encryptedDisks} Encrypted</result>"
    else
        echo "<result>${externalDisks} External Disks, ${encryptedDisks} Encrypted</result>"
    fi
fi
exit 0