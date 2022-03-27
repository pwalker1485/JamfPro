#!/bin/zsh

########################################################################
#                 Turn Bluetooth on using MDM commands                 #
#                       (Self Service policy)                          #
################## Written by Phil Walker July 2019 ####################
########################################################################
# Last Modified Mar 2022

## API Username & Password
## Jamf Pro Server Objects
## Note: API account must have CREATE/READ/UPDATE access to:
## • Computers
## Jamf Pro Server Actions
## • Send Computer Bluetooth Command

## requires macOS 10.13.4 or later

# Load is-at-least
autoload is-at-least

########################################################################
#                            Variables                                 #
########################################################################

############ Variables for Jamf Pro Parameters - Start #################
# Encrypted credentials
encryptedUsername="$4" # defined in the policy
encryptedPassword="$5" # defined in the policy
# Jamf Pro URL (https://JamfProURL)
jamfProURL="$6" # defined in the policy
############ Variables for Jamf Pro Parameters - End ###################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# Get serial number
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')
# Mac model (friendly name)
macModelFriendly=$(system_profiler SPHardwareDataType | grep "Model Name" | sed 's/Model Name: //' | xargs)
# OS product version
productVersion=$(/usr/bin/sw_vers -productVersion)
# Big Sur major version
bigSurMajor="11"
# Monterey major version
montereyMajor="12"
# Bluetooth power status
if is-at-least "$montereyMajor" "$osVersion"; then
    btPowerState=$(system_profiler SPBluetoothDataType | awk '/State/ {print $NF}')
else
    controllerPowerState=$(/usr/libexec/PlistBuddy -c "print ControllerPowerState" /Library/Preferences/com.apple.Bluetooth.plist 2>/dev/null)
    if [[ "$controllerPowerState" == "0" ]] || [[ "$controllerPowerState" == "false" ]]; then
        btPowerState="Off"
    else
        btPowerState="On"
    fi
fi
# Check if the Mac is running Big Sur or later
if is-at-least "$bigSurMajor" "$productVersion"; then
    # Jamf helper icon
    helperIcon="/System/Library/PreferencePanes/Bluetooth.prefPane/Contents/Resources/Bluetooth.icns"
else
    osVersion="macOS 10"
    # Jamf helper icon
    helperIcon="/System/Library/PreferencePanes/Bluetooth.prefPane/Contents/Resources/AppIcon.icns"
fi
# Jamf helper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
# Jamf helper title
helperTitle="Message from <Company Name IT Dept>"
# Jamf helper heading
helperHeading="Bluetooth Turned On"

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

function decryptString () 
{
# Decrypt user credentials
echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}

function getAuthToken ()
{
# Use Basic Authentication to get a new bearer token for API authentication
if ! is-at-least "$montereyMajor" "$osVersion"; then
    authToken=$(curl -X POST --silent -u "${apiUsername}:${apiPassword}" "${jamfProURL}/api/v1/auth/token" | python -c 'import sys, json; print json.load(sys.stdin)["token"]')
else
    authToken=$(curl -X POST --silent -u "${apiUsername}:${apiPassword}" "${jamfProURL}/api/v1/auth/token" | plutil -extract token raw -)
fi
}

function authTokenCheck ()
{
# Confirm that the auth token is valid
apiAuthCheck=$(curl --write-out %{http_code} --silent --output /dev/null "${jamfProURL}/api/v1/auth" --request GET --header "Authorization: Bearer ${authToken}")
}

function checkAndRenewAuthToken ()
{
# Verify that API authentication is using a valid token by running an API command
# which displays the authorization details associated with the current API user
authTokenCheck
# If the apiAuthCheck has a value of 200, that means that the current
# bearer token is valid and can be used to authenticate an API call
if [[ "$apiAuthCheck" -eq "200" ]]; then
    # If the current bearer token is valid, it is used to connect to the keep-alive endpoint. This will
    # trigger the issuing of a new bearer token and the invalidation of the previous one
    if ! is-at-least "$montereyMajor" "$osVersion"; then
        authToken=$(curl -X POST --silent -u "${apiUsername}:${apiPassword}" "${jamfProURL}/api/v1/auth/token" | python -c 'import sys, json; print json.load(sys.stdin)["token"]')
    else
        authToken=$(curl -X POST --silent -u "${apiUsername}:${apiPassword}" "${jamfProURL}/api/v1/auth/token" | plutil -extract token raw -)
    fi
else
    # If the current bearer token is not valid, this will trigger the issuing of a new bearer token
    # using Basic Authentication
   getAuthToken
fi
}

function invalidateToken ()
{
# Verify that API authentication is using a valid token
authTokenCheck
# If the apiAuthCheck has a value of 200, that means that the current
# bearer token is valid and can still be used to authenticate an API call
if [[ "$apiAuthCheck" -eq "200" ]]; then
    # Invalidate the token
    invalidateToken=$(curl "${jamfProURL}/api/v1/auth/invalidate-token" --silent  --header "Authorization: Bearer ${authToken}" -X POST)
fi
}

function menuBarItem ()
{
# Add the item to the menu bar (macOS Catalina or earlier only)
if [[ "$osVersion" == "macOS 10" ]]; then
    echo "${macModelFriendly} running macOS ${productVersion}, adding Bluetooth to the menu bar..."
    runAsUser open '/System/Library/CoreServices/Menu Extras/Bluetooth.menu/'
    echo "Bluetooth status and preferences available in the menu bar"
    helperMenuItem="Status and preferences can be found in the menu bar"
else
    echo "${macModelFriendly} running macOS ${productVersion}, Bluetooth status available in Control Center"
    helperMenuItem="Status and preferences can be found in Control Center"
fi
}

function jamfHelperBTOn ()
{
# Jamf helper to advise users Bluetooth is now on
"$jamfHelper" -windowType utility -icon "$helperIcon" -title "$helperTitle" \
-heading "$helperHeading" -description "Bluetooth has now been turned on ✅

${helperMenuItem}" &
}

########################################################################
#                         Script starts here                           #
########################################################################

# If Bluetooth is already on, advise the user
if [[ "$btPowerState" == "On" ]]; then
    echo "Bluetooth already turned on"
    menuBarItem
    jamfHelperBTOn
    sleep 10
    killall -13 "jamfHelper" &>/dev/null
    exit 0
else
    # Decrypt the username and password
    apiUsername=$(decryptString "$encryptedUsername" 'Salt value' 'Passphrase value')
    apiPassword=$(decryptString "$encryptedPassword" 'Salt value' 'Passphrase value')
    # Get a bearer token
    getAuthToken
    # Check the token
    checkAndRenewAuthToken
    echo "Turning Bluetooth on..."
    # Get the computer ID
    computerID=$(curl -sf --header "Authorization: Bearer ${authToken}" "${jamfProURL}/JSSResource/computers/serialnumber/${serialNumber}/subset/general" \
    -X GET -H "accept: application/xml" | xmllint --xpath "/computer/general/id/text()" - 2>/dev/null)
    # Send Enable Bluetooth command
    curl -sf --header "Authorization: Bearer ${authToken}" "${jamfProURL}/JSSResource/computercommands/command/SettingsEnableBluetooth/id/$computerID" -X POST &>/dev/null
fi
# Confirm that Bluetooth is now on
until [[ "$btPowerState" == "On" ]]; do
    sleep 1
    # Re-populate Bluetooth controller power status variable
    if is-at-least "$montereyMajor" "$osVersion"; then
        btPowerState=$(system_profiler SPBluetoothDataType | awk '/State/ {print $NF}')
    else
        controllerPowerState=$(/usr/libexec/PlistBuddy -c "print ControllerPowerState" /Library/Preferences/com.apple.Bluetooth.plist 2>/dev/null)
        if [[ "$controllerPowerState" == "0" ]] || [[ "$controllerPowerState" == "false" ]]; then
            btPowerState="Off"
        else
            btPowerState="On"
        fi
    fi
done
# Invalidate the authorisation token
invalidateToken
echo "Bluetooth now on"
menuBarItem
jamfHelperBTOn
sleep 10
killall -13 "jamfHelper" &>/dev/null
exit 0