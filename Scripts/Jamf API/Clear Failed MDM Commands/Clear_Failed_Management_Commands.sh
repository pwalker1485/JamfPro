#!/bin/zsh

########################################################################
#                 Clear Failed Management Commands                    #
################ Written by Phil Walker November 2019 ##################
########################################################################
# Modified Mar 2022

## API Username & Password
## Note: API account must have READ and UPDATE access to:
## • Computers
## New API privilege Flush MDM Commands is also now required
## This is found under Jamf Pro Server Actions

# Load is-at-least
autoload is-at-least

########################################################################
#                            Variables                                 #
########################################################################

# Encrypted credentials
encryptedUsername="$4" # defined in the policy
encryptedPassword="$5" # defined in the policy
# Jamf Pro URL
jamfProURL="$6" #defined in the policy
# Get serial number
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')
# OS product version
osVersion=$(sw_vers -productVersion)
# Monterey major version
montereyMajor="12"

########################################################################
#                            Functions                                 #
########################################################################

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

# Decrypt the username and password
apiUsername=$(decryptString "$encryptedUsername" 'Salt value' 'Passphrase value')
apiPassword=$(decryptString "$encryptedPassword" 'Salt value' 'Passphrase value')
# Get a bearer token
getAuthToken
# Check the token
checkAndRenewAuthToken
# Check for failed Management Commands
failedCommands=$(curl -sf --header "Authorization: Bearer ${authToken}" -H "accept: application/xml" "${jamfProURL}/JSSResource/computerhistory/serialnumber/${serialNumber}/subset/Commands" \
| xmllint --xpath "/computer_history/commands/failed[node()]" - 2>/dev/null)
# If failed commands are found, clear them all
if [[ -n "$failedCommands" ]]; then
    echo "Failed Management Commands found"
	# Getting the computer ID
    computerID=$(curl -sf --header "Authorization: Bearer ${authToken}" "${jamfProURL}/JSSResource/computers/serialnumber/${serialNumber}/subset/general" \
    -X GET -H "accept: application/xml" | xmllint --xpath "/computer/general/id/text()" - 2>/dev/null)
    untilCount="0"
    maxAttempts="5"
    until [[ "$failedCommands" == "" ]] || [[ "$untilCount" -eq "$maxAttempts" ]]; do
        (( untilCount++ ))
        echo "Attempt ${untilCount}: Clearing failed Management Commands..."
        # Cancel all failed commands (run the command a maximum of 5 times)
        curl -sf --header "Authorization: Bearer ${authToken}" "${jamfProURL}/JSSResource/commandflush/computers/id/${computerID}/status/Failed" -X DELETE &>/dev/null
        sleep 5
        # Re-populate variable
        failedCommands=$(curl -sf --header "Authorization: Bearer ${authToken}" -H "accept: application/xml" "${jamfProURL}/JSSResource/computerhistory/serialnumber/${serialNumber}/subset/Commands" \
        | xmllint --xpath "/computer_history/commands/failed[node()]" - 2>/dev/null)
    done
    if [[ -z "$failedCommands" ]]; then
		echo "All failed Management Commands cleared"
        # Invalidate the authorisation token
        invalidateToken
    else
        echo "Failed commands still found!"
        echo "Investigatation required, possible User Approved MDM issue"
        # Invalidate the authorisation token
        invalidateToken
        exit 1
    fi
else
	echo "No failed Management Commands found"
    # Invalidate the authorisation token
    invalidateToken
fi
exit 0