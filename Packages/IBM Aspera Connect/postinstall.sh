#!/bin/zsh

########################################################################
#                  IBM Aspera Connect - postinstall                    #
################## Written by Phil Walker Sept 2021 ####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# Logged in users home directory
loggedInUserHome=$(dscl . -read /Users/"$loggedInUser" NFSHomeDirectory | awk '{print $2}')
# Temp directory
tempDir="/usr/local/AsperaConnect"
# Installer
asperaConnectInstaller="${tempDir}/IBM Aspera Connect Installer.app/Contents/Resources/install"

########################################################################
#                            Functions                                 #
########################################################################

function runAsUser ()
{  
# Run commands as the logged in user
if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, unable to run commands as a user"
else
    launchctl asuser "$loggedInUserID" sudo -u "$loggedInUser" "$@"
fi
}

function cleanUp ()
{
# Remove temp directory
if [[ -d "$tempDir" ]]; then
    rm -rf "$tempDir"
    if [[ ! -d "$tempDir" ]]; then
        echo "Removed all temp content"
    else
        echo "Failed to remove temp content"
    fi
else
    echo "No temp content found, nothing to do"
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    echo "No user logged in, unable to continue!"
    echo "A user must be logged in for the installation to complete successfully"
    cleanUp
    exit 1
else
    echo "${loggedInUser} logged in, starting install..."
    # Check for the installer
    if [[ -e "$asperaConnectInstaller" ]]; then
        echo "IBM Aspera Connect installer found"
        # Run the installer as the logged in user
        runAsUser "$asperaConnectInstaller"
        sleep 2
        # Confirm installations
        asperaConnect="${loggedInUserHome}/Applications/Aspera Connect.app"
        if [[ -d "$asperaConnect" ]]; then
            asperaConnectVersion=$(defaults read "${asperaConnect}/Contents/Info" CFBundleShortVersionString)
            echo "Aspera Connect ${asperaConnectVersion} installed for ${loggedInUser}"
        else
            echo "Failed to install Aspera Connect for ${loggedInUser}"
        fi
        asperaCrypt="${loggedInUserHome}/Applications/Aspera Crypt.app"
        if [[ -d "$asperaCrypt" ]]; then
            asperaCryptVersion=$(defaults read "${asperaCrypt}/Contents/Info" CFBundleShortVersionString)
            echo "Aspera Crypt ${asperaCryptVersion} installed for ${loggedInUser}"
        else
            echo "Failed to install Aspera Crypt for ${loggedInUser}"
        fi
        ibmAsperaLauncher="${loggedInUserHome}/Applications/IBM Aspera Launcher.app"
        if [[ -d "$ibmAsperaLauncher" ]]; then
            ibmAsperaLauncherVersion=$(defaults read "${ibmAsperaLauncher}/Contents/Info" CFBundleShortVersionString)
            echo "IBM Aspera Launcher ${ibmAsperaLauncherVersion} installed for ${loggedInUser}"
        else
            echo "Failed to install IBM Aspera Launcher for ${loggedInUser}"
        fi
    else
        echo "IBM Aspera Connect installer not found!"
        cleanUp
        exit 1
    fi
fi
# Remove temp content
cleanUp
exit 0