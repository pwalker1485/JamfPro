#!/bin/zsh

########################################################################
#         Find all inactive versions of Java Development Kit - EA      #
################## Written by Phil Walker Apr 2021 #####################
########################################################################

########################################################################
#                            Variables                                 #
########################################################################

jdkCheck=$(find /Library/Java/JavaVirtualMachines -iname "*.jdk*" -maxdepth 1 | awk 'END {print NR}')

########################################################################
#                         Script starts here                           #
########################################################################

if [[ "$jdkCheck" -gt "0" ]]; then
    # Get the active version of Java
    activeJDK=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
    # Check for additional versions of Java Development Kit
    installedJDKs=$(find /Library/Java/JavaVirtualMachines -iname "*.jdk*" -maxdepth 1)
    for jdk in ${(f)installedJDKs}; do
        jdkVersion=$(defaults read "${jdk}/Contents/Info.plist" CFBundleVersion)
        jdkJVM=$(/usr/libexec/PlistBuddy -c "print :JavaVM:JVMVersion" "${jdk}/Contents/Info.plist" 2>/dev/null)
        if [[ "$jdkVersion" != "$activeJDK" ]] && [[ "$jdkJVM" != "$activeJDK" ]]; then
            if [[ "$jdkVersion" != "" ]]; then
                unusedJDKs+=($jdkVersion)
            else
                unusedJDKs+=($jdkJVM)
            fi
        fi
    done
    if [[ -z "${(@)unusedJDKs}" ]]; then
        echo "<result>None</result>"
    else
        echo "<result>$(printf '%s\n' "${(@)unusedJDKs}" | sort -n)</result>"
    fi
else
    echo "<result>None</result>"
fi
exit 0