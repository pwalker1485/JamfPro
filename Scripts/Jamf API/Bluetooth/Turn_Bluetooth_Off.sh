#!/bin/zsh

########################################################################
#               Send MDM Command to Disable Bluetooth                  #
################## Written by Phil Walker July 2019 ####################
########################################################################
# Edit Mar 2022

## API account must have CREATE/READ/UPDATE access to:
## • Computers
## Jamf Pro Server Actions
## • Send Computer Bluetooth Command

## requires macOS 10.13.4 or later

# Load is-at-least
autoload is-at-least

########################################################################
#                            Variables                                 #
########################################################################

# Encrypted credentials
encryptedUsername="$4" # defined in the policy
encryptedPassword="$5" # defined in the policy
# Jamf Pro URL (https://JamfProURL/JSSResource)
jamfProURL="$6" # defined in the policy
# Get serial number
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')
# OS product version
osVersion=$(sw_vers -productVersion)
# Monterey major version
montereyMajor="12"

########################################################################
#                            Functions                                 #
########################################################################

function getBluetoothStatus ()
{
# Bluetooth power status
if is-at-least "$montereyMajor" "$osVersion"; then
    controllerPowerState=$(system_profiler SPBluetoothDataType | awk '/State/ {print $NF}')
    if [[ "$controllerPowerState" == "Off" ]]; then
        btControllerStatus="Off"
    else
        btControllerStatus="On"
    fi
else
    controllerPowerState=$(/usr/libexec/PlistBuddy -c "print ControllerPowerState" /Library/Preferences/com.apple.Bluetooth.plist)
    if [[ "$controllerPowerState" == "0" ]] || [[ "$controllerPowerState" == "false" ]]; then
        btControllerStatus="Off"
    else
        btControllerStatus="On"
    fi
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
    invalidateToken=$(/usr/bin/curl "${jamfProURL}/api/v1/auth/invalidate-token" --silent  --header "Authorization: Bearer ${authToken}" -X POST)
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$btPowerStatus" == "0" ]] || [[ "$btPowerStatus" == "false" ]]; then
    echo "Bluetooth already turned off, nothing to do"
else
    # Decrypt the username and password
    apiUsername=$(decryptString "$encryptedUsername" 'Salt value' 'Passphrase value')
    apiPassword=$(decryptString "$encryptedPassword" 'Salt value' 'Passphrase value')
    echo "Sending Disable Bluetooth remote command..."
    # Get the computer ID
    computerID=$(curl -sfku "${apiUsername}:${apiPassword}" -H "accept: application/xml" "${jamfProURL}/computers/serialnumber/${serialNumber}" \
    | xmllint --xpath '/computer/general/id/text()' -)
    # Send Disable Bluetooth command
    curl -sfku "${apiUsername}:${apiPassword}" -H "accept: application/xml" "${jamfProURL}/computercommands/command/SettingsDisableBluetooth/id/${computerID}" -X POST &>/dev/null
    # Waiting for the command to be actioned and the Bluetooth controller state to change can take several minutes so only check the command was sent
    commandResult="$?"
    if [[ "$commandResult" -eq "0" ]]; then
        echo "Disable Bluetooth remote command sent successfully"
    else
        # Try sending the Disable Bluetooth command again
        curl -sfku "${apiUsername}:${apiPassword}" -H "accept: application/xml" "${jamfProURL}/computercommands/command/SettingsDisableBluetooth/id/${computerID}" -X POST &>/dev/null
        commandResult="$?"
        if [[ "$commandResult" -eq "0" ]]; then
            echo "Disable Bluetooth remote command sent successfully"
        else
            echo "Failed to send remote command, Bluetooth will remain enabled"
        fi
    fi
fi
exit 0