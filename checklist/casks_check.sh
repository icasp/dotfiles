#!/usr/bin/env bash

#set -x

CASKS_INSTALL='../setup/casks.sh'

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

function buildExpectedList()
{
  while read l
  do
    if (($inAppList))
    then
      checkAppEnd $l && break
      if [ -z "${expected+set}" ]
      then
        expected="$l"
      else
        expected="$expected\n$l"
      fi
    else
      checkAppStart $l && inAppList=1
    fi
  done < $CASKS_INSTALL
}

function buildInstalledlist()
{
  installed=$(brew cask list)
}

brew list | grep -q cask && \
  echo "Installing 'cask' to provide report..." && \
  brew tap caskroom/cask && \
  brew tap caskroom/versions

buildExpectedList
#echo $expected
buildInstalledlist
#echo $installed

echo -e "\n\033[1mCasks differences ('+' is installed but not expected, '-' is missing) :\033[0m"
diff -u <(echo -e $expected | sort) <(echo -e $installed | tr ' ' '\n' | sort) 2> /dev/null | grep -E -- '^[\+-]\w' | sort

exit 0
