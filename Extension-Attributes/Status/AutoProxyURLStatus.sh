#!/bin/zsh

########################################################################
#                     Auto Proxy URL Status - EA                       #
################## Written by Phil Walker Mar 2021 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

# All network services
networkServices=$(/usr/sbin/networksetup -listallnetworkservices | tail +2)
# Bauer PAC file
pacFile="http://proxy.domain.fqdn/default.pac"

########################################################################
#                         Script starts here                           #
########################################################################

# Auto Proxy URL Status
proxyStatus="Not Set"
for service in ${(f)networkServices}; do
    # Check Auto Proxy URL for all services
	autoProxyURLLocal=$(/usr/sbin/networksetup -getautoproxyurl "$service" | head -1 | cut -c 6-)
    if [[ "$autoProxyURLLocal" == "$pacFile" ]]; then
        # If any interface has the Auto Proxy URL set then break and define the variable
        proxyStatus="Set"
        break
    fi
done
echo "<result>$proxyStatus</result>"
exit 0