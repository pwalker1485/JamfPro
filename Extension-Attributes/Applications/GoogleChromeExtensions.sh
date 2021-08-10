#!/bin/bash

########################################################################
#                     Google Chrome Extensions - EA                    #
######################## written by Phil Walker ########################
########################################################################

# Grabbed this from https://www.jamf.com/jamf-nation/discussions/11307/chrome-extension-reporting
# Has slight amendments to filter out Google stock extensions
# Added legacy Google Search extension to exclusions

########################################################################
#                            Variables                                 #
########################################################################

# Get the logged in user
loggedInUser=$(stat -f %Su /dev/console)
# Extension exclusions (Google stock extensions)
chromeExclusions="Chrome Media Router • pkedcjkdefgpdelpbcmbmeomcjbeemfm\|• aapocclcgogkmnckokdopfmhonfmgoek\|• aohghmighlieiainnegkcijnfilokake\|• apdfllckaahabafndbhieahigkjlhalf\|• blpcfgokakmgnkcojhhkbfbldkacnbeo\|• felcaaldnbdncclmgdcncolpebgiejap\|• ghbmnnjooekpmoecnnnilnnbdlolhkhi\|• nmmhkkegccagdldgiimedpiccmgmieda\|• pjkljhegncpnkpknbcohdijeoejaedia\|Google Search • coobgpohoikkiipiblmjeljniedjpjpf"

########################################################################
#                            Functions                                 #
########################################################################

# Grab a string from a json formatted file
function jsonVal () 
{
temp=$(echo $json | sed -e 's/\\\\\//\//g' -e 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed -e 's/\"\:\"/\|/g' -e 's/\]//' -e 's/[\,]/ /g' -e 's/\"//g' | grep -w $property | tail -1)
echo ${temp##*|}
}

# Get logged in users installed Extensions
function getUserExtensions ()
{
cd "/Users/${loggedInUser}/Library/Application Support/Google/Chrome/Default/Extensions"
for d in *; do
    JSONS=$(find "/Users/${loggedInUser}/Library/Application Support/Google/Chrome/Default/Extensions/$d" -maxdepth 3 -name "manifest.json" )
    while read -r JSON; do
        NAME=$(awk -F'"' '/"name"/{print $4}' "$JSON")
        if [[ "$NAME" == "" ]]; then
            NAME=$(awk -F'"' '/"default_title"/{print $4}' "$JSON")
        fi
    done < <(echo "$JSONS")
    if [[ "$NAME" =~ "_MSG_" ]]; then
        property=$(echo $NAME | sed -e "s/__MSG_//" -e "s/__//" )
        myPath=$(echo $JSONS | sed "s:manifest.json:_locales/en_US/messages.json:" )
        if [ ! -f "$myPath" ]; then
            myPath=$(echo $JSONS | sed "s:manifest.json:_locales/en/messages.json:" )
        fi
        json=$(cat "$myPath" | sed '/description/d')
        NAME=$(jsonVal | sed 's/.*://' )
        if [ -z "$NAME" ]; then
            property=$(echo "-i $property")
            NAME=$(jsonVal | sed 's/.*://')
        fi
    fi
    if [ "${#d}" -eq 32 ]; then
        EXTS+=("${NAME} • ${d}\n")
    fi
done
}

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$loggedInUser" == "" ]] || [[ "$loggedInUser" == "root" ]]; then
    "<result>No user logged in</result>"
else
    if [[ ! -d "/Applications/Google Chrome.app" ]]; then
        echo "<result>No 3rd party extensions installed</result>"
    else    
        if [[ ! -d "/Users/${loggedInUser}/Library/Application Support/Google/Chrome/Default/Extensions" ]]; then
            echo "<result>No 3rd party extensions installed</result>"
        else
            getUserExtensions
            installedExtensions=$(echo -e "${EXTS[@]}" | sed -e 's/^[ \t]*//' -e '/^$/d' | grep -v "$chromeExclusions" | sort)
            if [[ "$installedExtensions" != "" ]]; then
                echo "<result>$installedExtensions</result>"
            else
                echo "<result>No 3rd party extensions installed</result>"
            fi
        fi
    fi
fi
exit 0