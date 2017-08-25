#!/usr/bin/env bash

EXPECTED_FILE='./apps.expected'

## Thanks to patrik @ stackoverflow
function elementInArray()
{
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

IGNORELIST=(
  App_Store
  Automator
  Calculator
  Calendar
  Chess
  Contacts
  Dictionary
  FaceTime
  Font_Book
  Image_Capture
  Launchpad
  Mail
  Maps
  Messages
  Mission_Control
  Notability
  Notes
  Photo Booth
  Photos
  Preview
  QuickTime_Player
  Reminders
  Safari
  Siri
  Stickies
  System_Preferences
  TextEdit
  Time Machine
  Utilities
  iBooks
  iTunes
)

allInstalled=$(ls /Applications | sed 's/\.app//' | tr ' ' '_')
#echo $installed

if [ ! -z $1 ] && [ $1 == "buildref" ]
then
  rm -f $EXPECTED_FILE
  for a in $allInstalled
  do
    elementInArray $a "${IGNORELIST[@]}" || echo $a >> $EXPECTED_FILE
  done
  echo "Reference file '$EXPECTED_FILE' built"
  exit 0
fi

for a in $allInstalled
do
  elementInArray $a "${IGNORELIST[@]}" || if [ -z "${installed+set}" ]; then installed="$a"; else installed="$installed\n$a"; fi
done

expected=$(cat $EXPECTED_FILE)

echo -e "\033[1mApps differences ('+' is installed but not expected, '-' is missing) :\033[0m"
diff -u <(echo -e $expected | tr ' ' '\n' | sort) <(echo -e $installed | tr ' ' '\n' | sort) 2> /dev/null | grep -E -- '^[\+-]\w' | sort

exit 0
