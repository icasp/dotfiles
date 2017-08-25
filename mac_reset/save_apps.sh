#!/usr/bin/env bash

source globals.sh

apps=(
  VMware_Fusion
)

mkdir -p $BACKUP/apps/
#cd $SYSTEM/Applications

for a in ${apps[@]}
do
  status="${YELLOW}Backing up app '$a'...${RESET}"
  printf "$status"
  eval tar -C $SYSTEM/Applications -czf $BACKUP/apps/$a.tgz $(echo $a | sed 's/_/\\ /')".app" &> /dev/null \
    && printf " ${GREEN}ok${RESET}\n" \
    || printf " ${RED}FAIL${RESET}\n"
done
