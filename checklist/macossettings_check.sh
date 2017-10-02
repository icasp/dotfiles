#!/usr/bin/env bash

MACOS_SETTINGS='../setup/macossettings.sh'

BLUEBOLD='\033[1;34m'
RED='\033[31m'
ORANGEBOLD='\033[1m'
RESET='\033[m'

echo -e "\n${ORANGEBOLD}Checking macOS settings...${RESET}"
echo -e "${ORANGEBOLD}Will only check for 'defaults' changes, other settings have not been implemented (yet?).${RESET}"
# Ask for the administrator password upfront.
sudo -v
echo -e "Not checked :${RED}"
grep -vE '(^(#|$|echo|exit)|defaults|sudo -v)' $MACOS_SETTINGS
echo -e "${RESET}"

OLDIFS=$IFS
IFS=$'\n'
settings=$(grep -E '^[^#](udo defaults|efaults)' $MACOS_SETTINGS)

function boolResolve() #$expected $result
{
  localexp=${1//[$'"']}
  localres=${2//[$'"']}
  if [ -z $localexp ]; then return 12; fi
  if [ $localres = $localexp ]; then return 0; fi
  if ( [ $localexp = "true" ] || [ $localexp = "True" ] ) && [ $localres = 1 ]; then return 0; fi
  if [ $localexp = "false" ] && [ $localres = 0 ]; then return 0; fi
  property=${item##* }
  echo $localres | grep -vE '[{\[]' > /dev/null && return 1
  echo $localres | grep '{(' > /dev/null && echo $localres | grep -- "$property" > /dev/null && return 0 || straw='exist'
  return 1
}

WRITESPLIT_REG='(^.*defaults) (-.+Host )?(write|read) (.+) ([^-][a-zA-Z0-9\.-]+|\"[^-][ a-zA-Z0-9\.-]+\") (-[a-zA-Z-]+ )?(\".+\"|\"?[a-zA-Z0-9 ]+\"?)$'
READSPLIT_REG='(^.*defaults) (-.+Host )?(write|read) (.+) ([^-][a-zA-Z0-9\.-]+|\"[^-][ a-zA-Z0-9\.-]+\")'

notFound=0
for l in $settings
do
  IFS=$OLDIFS
  #check=$(echo $l | sed -E 's/(^.*) write (.+) -*[a-zA-Z-]+ (.+|[0-9])$/\1 read \2/')
  check=$(echo $l | sed -E "s/$WRITESPLIT_REG/\1 \2 read \4 \5/")
  item=$(echo $check | sed -E "s/$READSPLIT_REG/\4 \5/")
  expected=$(echo $l | awk '{print $NF}')
  #^.*defaults read (.+) ([^-][a-zA-Z0-9\.-]+|\"[^-][ a-zA-Z0-9\.-]+\") (-[a-zA-Z-]+ )?(\".+\"|\"?[a-zA-Z0-9 ]+\"?)$
  result=$($check 2>&1)   #### ISSUE : Will fail on key with spaces in name, may fix "one day" because only 2 cases referenced for now
  straw=${result##* }
  checkReturn=$?
  #[[ $checkReturn = 0 ]] && color='' || color=${RED}
  if [ $checkReturn = 0 ] && boolResolve ${expected//[$'\t\r\n']} ${result//[$'\t\r\n']}
  then
    continue
  elif [ "$straw" == "exist" ]
  then
    ((notFound++))
    test -z "${notFoundList+set}" && notFoundList="$check\n" || notFoundList=$notFoundList$check"\n"
  else
    echo -e "${BLUEBOLD}Failing $item with :${RESET}"
    echo -e "${RED} Value is ${result}${RESET} but expected $expected"
  fi
  #IFS=$'\n'
done
if [ $notFound -gt 0 ]
then
  echo -e "\n${ORANGEBOLD}The following $notFound preferences could not be found (not set / non existing) :${RESET}"
  echo -e "$notFoundList"
fi

IFS=$OLDIFS

exit 0
