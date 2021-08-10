#!/bin/zsh

########################################################################
#  List Logged In User's Bluetooth Devices (Paired, Configured, etc.)  #
################ Written by Suleyman Twana & Phil Walker ###############
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Get the logged in users ID
loggedInUserID=$(id -u "$loggedInUser")
# Get the logged in user UID
loggedInUserUID=$(dscl . -read /Users/"$loggedInUser" UniqueID | awk '{print $2}')
# Jamf Connect App
jamfConnect="/Applications/Jamf Connect.app"
# temp file
tempFile="/private/tmp/BluetoothDevicesEA.txt"

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

function getFirstName ()
{
# Get first name of the logged in user
if [[ -d "$jamfConnect" ]]; then
    # Check Jamf Connect state
    jcFirstName=$(runAsUser defaults read com.jamf.connect.state UserFirstName)
    if [[ "$jcFirstName" != "" ]]; then
        firstName="$jcFirstName"
    fi
else
    # Use dscl as a fallback
    if [[ "$loggedInUserUID" -lt "1000" ]]; then
        firstName=$(dscl . -read /Users/"$loggedInUser" | grep -A1 "RealName:" | sed -n '2p' | awk '{print $1}' | sed s/,//)
    else
        firstName=$(dscl . -read /Users/"$loggedInUser" | grep -A1 "RealName:" | sed -n '2p' | awk '{print $2}' | sed s/,//)
    fi
fi
}

########################################################################
#                         Script starts here                           #
########################################################################

# Get the user first name
getFirstName
# Check Bluetooth data in System Profiler
btDevicesAll=$(system_profiler SPBluetoothDataType > "$tempFile")
# Check for paired devices
btDevices1=$(cat < "$tempFile" | grep -i "$firstName" | grep -vi "wireless" | grep -vi "iPhone-Wirel" | sed 's/://g' | sed -e 's/^[ \t]*//' | tr -cd '\11\12\15\40-\176' | sort -u)
btDevices2=$(cat < "$tempFile" | grep -i "magic" | sed 's/Services//g' | sed 's/://g' | sed -e 's/^[ \t]*//' | sort -u)
btDevices3=$(cat < "$tempFile" | grep -i "Galaxy\|HUAWEI\|Samsung" | sed 's/://g' | sed -e 's/^[ \t]*//' | sort -u)
# Check results
if [[ "$firstName" == "" ]] && [[ "$btDevices2" == "" ]] && [[ "$btDevices3" == "" ]]; then
    echo "<result></result>"
elif [[ "$firstName" == "" ]] && [[ "$btDevices2" != "" || "$btDevices3" != "" ]]; then
    echo "<result>"$(echo "${btDevices2} ${btDevices3}" | tr -d '\r' | xargs)"</result>"
else
    if [[ "$btDevices1" == "" ]] && [[ "$btDevices2" == "" ]] && [[ "$btDevices3" == "" ]]; then
        echo "<result></result>"
    else
        echo "<result>"$(echo "${btDevices1} ${btDevices2} ${btDevices3}" | tr -d '\r' | xargs)"</result>"
    fi
fi
# Remove temp file
rm "$tempFile"
exit 0