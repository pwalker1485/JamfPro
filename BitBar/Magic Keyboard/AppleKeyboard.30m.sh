#!/bin/bash
# <bitbar.title>Apple Wireless or Magic Keyboard Status</bitbar.title>
# <bitbar.version>2.0</bitbar.version>
# <bitbar.author>Phil Walker</bitbar.author>
# <bitbar.author.github>pwalker1485</bitbar.author.github>
# <bitbar.desc>Displays battery level or charge status (Magic Keyboard only) for an Apple Wireless or Magic Keyboard</bitbar.desc>
# <bitbar.image>http://i.imgur.com/CtqV89Y.jpg</bitbar.image>

# Apple Wireless Keyboard battery level
wirelessKeyboard=$(ioreg -c AppleBluetoothHIDKeyboard | grep "BatteryPercent" | grep -F -v \{ | sed 's/[^[:digit:]]//g')
# Apple Magic Keyboard battery level
magicKeyboard=$(ioreg -c AppleDeviceManagementHIDEventService -r -l | grep -i "Keyboard" -A 20 | grep "BatteryPercent" | grep -F -v \{ | sed 's/[^[:digit:]]//g')
# Check if a Magic Keyboard is connected via USB
chargeStatus=$(ioreg -p IOUSB -w0 | sed 's/[^o]*o //; s/@.*$//' | grep -v '^Root.*' | grep "Magic*")

function chargeStatus ()
{
# Display lightning icon if Magic Keyboard is connected via USB
if [[ "$chargeStatus" == "Magic Keyboard" ]]; then
  echo "⚡️"
fi
}

function appleKeyboard ()
{
#Set the colour based on the remaining charge for either keyboard
if [[ "$wirelessKeyboard" ]]; then
  if [[ "$wirelessKeyboard" -le 20 ]]; then
    echo "⌨️${wirelessKeyboard}% | color=red"
  else
    echo "⌨️${wirelessKeyboard}%"
  fi
fi
if [[ "$magicKeyboard" ]]; then
  if [[ "$magicKeyboard" -le 20 ]]; then
    echo "⌨️${magicKeyboard}% | color=red"
  else
    echo "⌨️${magicKeyboard}%"
  fi
fi
}

function chargeRequired() {
#If using an Apple Magic Keyboard show additional info if the battery level is low
if [[ "$magicKeyboard" ]]; then
  if [[ "$magicKeyboard" -le 20 && "$magicKeyboard" -ge 11 ]]; then
  echo "🔋Level Low | color=red"
elif [[ "$magicKeyboard" -le 10 ]]; then
  echo "🔋Level Critical | color=red"
  echo "⚡️Charge Required | color=red"
  fi
fi
}

echo "$(chargeStatus)$(appleKeyboard)"
echo "---"
echo "$(chargeRequired)"