#!/bin/zsh

########################################################################
#               Kerberos Configuration Default Realm - EA              #
#################### Written by Phil Walker May 2021 ###################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# Kerberos config file
kerbConfig="/etc/krb5.conf"
# Kerberos realm
defaultRealm="YOUR.DOMAIN"
# OS product version
osVersion=$(sw_vers -productVersion)
# Big Sur major version
bigSurMajor="11"

########################################################################
#                         Script starts here                           #
########################################################################

# Load is-at-least
autoload is-at-least
if ! is-at-least "$bigSurMajor" "$osVersion"; then
    # Check for an existing krb5 config file
    if [[ -e "$kerbConfig" ]]; then
        # If found, then check the value set for default realm
        realmCheck=$(cat "$kerbConfig" | grep "default_realm" | awk '{print $3}')
        if [[ "$realmCheck" != "" ]]; then
            echo "<result>${realmCheck}</result>"
        else
            echo "<result>Not Set</result>"
        fi
    else
        echo "<result>Not Found</result>"
    fi
else
    if [[ -e "$kerbConfig" ]]; then
        echo "<result>Found and Not Required</result>"
    else
        echo "<result>Not Required</result>"
    fi
fi
exit 0