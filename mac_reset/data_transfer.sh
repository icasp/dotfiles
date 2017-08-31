#!/usr/bin/env bash

source globals.sh

function targetExists()
{
  target=$(echo "${@//\'}" | sed -E 's/([^\[*]+)(\[.+\])*(\*)?/\"\1\"\2\3/g')
  eval ls $target &> /dev/null && return 0
  return 1
}

function transfer() # targets list file name, directory
{
  while read l
  do
    if [[ "$l" == "#"* ]] || [[ "$l" == "" ]]; then continue; fi
    if [[ "$l" == "="* ]]
    then
      if [ $OPERATION == "restore" ]
      then
        echo -e "! ${GREEN}Not automatically restoring '${l:1}' as per configured${RESET}"
        continue
      else
        l=${l:1}
      fi
    fi
    targetExists "'$SRC/$2/$l'" || { echo -e "${RED}Skipping item '$l' because source '$SRC/$2/$l' was not found${RESET}" && continue ; }
    status="${YELLOW}Now processing item '$l'...${RESET}"
    printf "$status"
    target=$(echo "$SRC/$2/$l" | sed -E 's/([^\[*]+)(\[.+\])*(\*)?/\"\1\"\2\3/g')
    eval rsync -a $OPTS $target $DST/ \
      && printf " ${GREEN}ok${RESET}\n" \
      || printf " ${RED}FAIL${RESET}\n"
  done < "$LISTS/$1.list"
}

function checkArgsCount()
{
  if [ $1 -lt $2 ]
  then
    echo -e "!! $0 : ${RED}Insufficient arguments passed from transfer init, aborted to avoid data corruption${RESET}"
    exit 12
  fi
}

function proceedWith()
{
  checkArgsCount $# 3
  test -e "$DST/$2" || mkdir -p $DST/$2
  echo -e "${ORANGEBOLD}Starting ${@:3} transfer from $SRC/$2 to $DST/$2...${RESET}" \
    && time transfer "$1" "$2"
}

function initTransfers()
{
  proceedWith homefolders Users/$USER Home Folders
  proceedWith library Users/$USER/Library Library
  proceedWith application_support Users/$USER/Library/Application\ Support Application Support
  proceedWith containers Users/$USER/Library/Containers Containers
}

function checkList() # targets file
{
  echo -e "${ORANGEBOLD}Checking $1 list...${RESET}"
  while read l
  do
    test -e $1
  done < "$LISTS/$1.list"
}

function backupCompleteness()
{
  checkList homefolders
}

function confirmRestore()
{
  echo -e "\033[1mPress 'y' to confirm restore of '$SRC' on '$DST', otherwise will skip in 10 seconds...\033[0m"
  for i in $(seq 10 1)
  do
    read -p $i... -n 1 -t 1 a && break
  done
  if [ $a == "y" ]
  then
    echo -e "\nLet's go"
  else
    echo -e "\n!!OK, next time maybe?"
    exit 1
  fi
}

OPERATION=$1

case $OPERATION in
  'backup')
    SRC=$SYSTEM
    DST=$BACKUP
    OPTS='-Ru --delete' # --inplace'
    initTransfers
    ;;
  'restore')
    SRC=$BACKUP
    DST=$SYSTEM
    confirmRestore
    initTransfers
    ;;
  *)
    echo -e "!! $0 : ${RED}You need to specify either 'backup' or 'restore' as an argument${RESET}"
    ;;
esac

exit 0

