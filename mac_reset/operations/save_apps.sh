#!/usr/bin/env bash
sPath=$([[ $0 == /* ]] && dirname $0 || dirname "$(pwd)/$0")
ENVERR="\033[31m!! Environment not initialized, if calling child script then use 'bash -c \"source [../]core.source && bash $0\"'\033[m"
(($COREINIT)) || { echo -e $ENVERR && exit 12 ; }

apps=(
  VMware_Fusion
)

mkdir -p $BACKUP/apps/
#cd $SYSTEM/Applications

for a in ${apps[@]}
do
	test -e "$(echo $a | sed 's/_/\\ /').app" || { echo -e "${RED}Could not backup $a because couldn't be found${RESET}" ; continue ; } 
  status="${YELLOW}Backing up app '$a'...${RESET}"
  printf "$status"
  eval tar -C $SYSTEM/Applications -czf $BACKUP/apps/$a.tgz $(echo $a | sed 's/_/\\ /')".app" &> /dev/null \
    && printf " ${GREEN}ok${RESET}\n" \
    || printf " ${RED}FAIL${RESET}\n"
done
