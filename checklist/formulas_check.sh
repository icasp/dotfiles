#!/usr/bin/env bash

#set -x

logFile="$(echo $DOTSRC)/logs/$(echo $0 | sed $SEDOPT 's/^.+\/([a-z_]+\.)sh$/\1log/')"
(($LIVEDUMP)) && output='&1' || output=$logFile
(($LIVEDUMP)) || echo -e "\n##### Starting operation $(date)\n" >> $output 2>&1

FORMULAS_INSTALL='../setup/formulas.sh'

# 0 for BOOL false, else is true
inAppList=0

function checkAppStart()
{
  echo $1 | grep -E '^apps=\($' &> /dev/null
}

function checkAppEnd()
{
  echo $@ | grep -E '^\)$' &> /dev/null
}

function isValidFormula()
{
  formula=$(echo $@ | grep -v 'cask')
  echo $formula | grep -E '\w' &> /dev/null
}

function buildExpectedList()
{
  while read l
  do
    if (($inAppList))
    then
      checkAppEnd $l && break
      isValidFormula $l || continue
      if [ -z "${expected+set}" ]
      then
        expected="$l"
      else
        expected="$expected\n$l"
      fi
    else
      checkAppStart $l && inAppList=1
    fi
  done < $FORMULAS_INSTALL
}

function buildInstalledlist()
{
  installed=''
  deps=($(brew deps --installed | grep -v ': $' | awk -F ': ' '{print $2}' | tr ' ' '\n' | sort | uniq))
  #echo $deps
  for f in $(brew list)
  do
    elementInArray $f "${deps[@]}" || if [ -z "${installed+set}" ]; then installed="$f"; else installed="$installed\n$f"; fi
  done
}

## Thanks to patrik @ stackoverflow
function elementInArray()
{
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

buildExpectedList
#echo $expected
buildInstalledlist
#echo $installed

echo -e "\n\033[1mFormulas differences ('+' is installed but not expected, '-' is missing) :\033[0m"
diff -u <(echo -e $expected | sort) <(echo -e $installed | tr ' ' '\n' | sort) 2> /dev/null | grep -E -- '^[\+-]\w' | sort

exit 0
