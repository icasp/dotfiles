#!/usr/bin/env bash

BACKUP='/Volumes/PROTEUS/myplex'
SYSTEM='/'
#SYSTEM='dummy'
LISTS='./transfer/'
#USER=$(whoami)
USER='icasp'

BLUEBOLD='\033[1;34m'
RED='\033[31m'
ORANGEBOLD='\033[1m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RESET='\033[m'

SH='sh'
which bash &> /dev/null && SH=$(which bash)

DOTSRC=$([[ $0 == /* ]] && dirname $0 || dirname "$(pwd)/$0")

function sequenceAbort()
{
  echo -e "\n${RED}!! Restore sequence aborted, please assess status before resuming or moving on?\n${RESET}"
  exit 12
}
