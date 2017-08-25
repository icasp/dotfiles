#!/usr/bin/env bash

test -e globals.sh && source globals.sh || { echo -e "\n\033[31m!! Please execute scripts from 'mac_reset' folder\n\033[m" && exit 12; }

function escapeRoute()
{
  echo '' && read -p "End of audit sequence, enter 'q' to quit or anything else to start backup : " ANS
  if [ $ANS == 'q' ]; then
    exit 0
  fi
}

checks=(
  'zprezto repo should be in sync if forked'
  'dotfiles repo should be in sync'
)
echo -e "\n${BLUEBOLD} Recommended checks before starting backup procedure :"
for c in "${checks[@]}"
do
  echo -e "- $c"
done
echo -e "${RESET}\r"

escapeRoute

$SH ../audit.sh
$SH audit_apps.sh

escapeRoute

crontab -l > $BACKUP/crontab.list
$SH data_transfer.sh backup
$SH save_apps.sh
