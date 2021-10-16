#!/bin/zsh

########################################################################
#             Download and Install Applications (Source: DMG)          #
################### Written by Phil Walker June 2021 ###################
########################################################################
# Designed to be used in a Payload-Free Package
# Source must be a DMG containing the application bundle

########################################################################
#                            Variables                                 #
########################################################################

# Application Name - must match exact name of the application bundle without the extension e.g. Slack
appName="Slack"
# Target URL
targetURL="https://slack.com/ssb/download-osx-universal"
# Destination Download URL
downloadURL=$(curl --head --silent --location --output /dev/null --write-out "%{url_effective}\n" "$targetURL")
# Download directory
downloadDir="/private/var/tmp/${appName}Download"

########################################################################
#                            Functions                                 #
########################################################################

function cleanUp ()
{
# Remove temp directory
if [[ -d "$downloadDir" ]]; then
    rm -rf "$downloadDir"
    if [[ ! -d "$downloadDir" ]]; then
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

# Create the temporary directory
mkdir "$downloadDir"
# If the app is installed, get the version number for comparison (If possible)
if [[ -d "/Applications/${appName}.app" ]]; then
	currentInstalledVer=$(defaults read /Applications/${appName}.app/Contents/Info CFBundleShortVersionString 2>/dev/null)
    if [[ "$currentInstalledVer" == "" ]]; then
        echo "${appName} already installed"
        echo "Unable to determine installed version"
        currentInstalledVer="Version not found"
    else
        echo "${appName} already installed"
	    echo "Current installed version: $currentInstalledVer"
    fi
else
    echo "${appName} not currently installed"
    currentInstalledVer="None"
fi
# Download DMG
echo "Downloading ${appName}..."
curl --silent --output "${downloadDir}/${appName}.dmg" "$downloadURL"
# Wait for a few seconds before the install
sleep 2
if [[ -f "${downloadDir}/${appName}.dmg" ]]; then
    # Remove the previous version
    if [[ -d "/Applications/${appName}.app" ]]; then
        rm -rf "/Applications/${appName}.app"
        if [[ ! -d "/Applications/${appName}.app" ]]; then
            echo "Previous version removed"
        else
            echo "Failed to remove previous version"
        fi
    fi
    echo "Installing ${appName}..."
    # Mount the DMG
    appVolume=$(hdiutil attach -nobrowse "${downloadDir}/${appName}.dmg" | grep /Volumes | sed -e 's/^.*\/Volumes\///g')
    sleep 2
    # Copy the new version
    ditto -rsrc "/Volumes/${appVolume}/${appName}.app" "/Applications/${appName}.app"
    sleep 2
    # Unmount the volume
    hdiutil unmount -force "/Volumes/$appVolume" &>/dev/null
    # Wait a few seconds before checking the installed version
    sleep 2
    if [[ -d "/Applications/${appName}.app" ]]; then
        # Remove the quarantine attribute
        xattr -rd com.apple.quarantine "/Applications/${appName}.app" &>/dev/null
        # Set the correct ownership
        chown -R root:wheel "/Applications/${appName}.app"
        # Check the version
        latestInstallVer=$(defaults read /Applications/${appName}.app/Contents/Info CFBundleShortVersionString 2>/dev/null)
        if [[ "$currentInstalledVer" == "$latestInstallVer" ]]; then
            echo "Reinstalled the same version of ${appName}" # This is pretty much pointless but we did it anyway
        elif [[ "$currentInstalledVer" == "Version not found" ]] && [[ "$latestInstallVer" == "" ]]; then
            echo "Successfully installed ${appName}, unable to determine version" # Application doesn't have the CFBundleShortVersionString key in the Info plist
        elif [[ "$currentInstalledVer" == "None" ]] && [[ "$latestInstallVer" == "" ]]; then
            echo "Successfully installed ${appName}, unable to determine version" # Application doesn't have the CFBundleShortVersionString key in the Info plist
        else
            echo "Successfully installed ${appName} ${latestInstallVer}"
        fi
    else
        echo "Failed to install ${appName}!"
        # Remove temp content
        cleanUp
        exit 1
    fi
else
    echo "Failed to download ${appName}, exiting!"
    # Remove temp content
    cleanUp
    exit 1
fi
# Remove temp content
cleanUp
exit 0