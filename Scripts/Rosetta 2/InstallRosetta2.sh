#!/bin/zsh

########################################################################
#                 Install Rosetta 2 on Apple Silicon Macs              #    
#################### Written by Phil Walker Nov 2020 ###################
########################################################################
# Edit July 2021

########################################################################
#                            Variables                                 #
########################################################################

# OS version
osVersion=$(sw_vers -productVersion)
# Big Sur
minReqOS="11"
# Mac model
macModelFull=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)
# CPU Architecture
cpuArch=$(/usr/bin/arch)
# CPU brand
cpuBrand=$(sysctl -n machdep.cpu.brand_string)

########################################################################
#                         Script starts here                           #
########################################################################

# Load is-at-least
autoload is-at-least
# Make sure it's running Big Sur or later
if is-at-least "$minReqOS" "$osVersion"; then
    echo "$macModelFull running ${osVersion}"
    # Check for an ARM chip
    if [[ "$cpuArch" == "arm64" ]]; then
        echo "CPU detected: ${cpuBrand}"
        echo "Rosetta 2 required"
        # Check if the system can run x86_64 code with the arch binary,
        # perform a non-interactive install of Rosetta 2 if required
        arch -x86_64 /usr/bin/true 2>/dev/null
        commandResult="$?"
        if [[ "$commandResult" -eq "1" ]]; then
            echo "Installing Rosetta 2..."
            softwareupdate --install-rosetta --agree-to-license
            sleep 2
            # Check if the system can now run x86_64 code with the arch binary
            arch -x86_64 /usr/bin/true 2>/dev/null
            commandResult="$?"
            if [[ "$commandResult" -eq "0" ]]; then
        	    echo "Rosetta 2 has been successfully installed"
            else
        	    echo "Rosetta 2 installation failed!"
                exit 1
            fi
        else
    	    echo "Rosetta 2 is already installed, nothing to do"
        fi
    else
        echo "CPU detected: ${cpuBrand}"
        echo "No need to install Rosetta 2"
    fi
else
    echo "$macModelFull running ${osVersion}"
    echo "No requirement for Rosetta 2"
fi
exit 0