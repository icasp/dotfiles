#!/usr/bin/env bash

test -e globals.sh && source globals.sh || { echo -e "\n\033[31m!! Please execute scripts from 'mac_reset' folder\n\033[m" && exit 12; }

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

function saveButData()
{
	escapeRoute 'AUDIT'
	cd .. && $SH audit.sh || sequenceAbort
	cd - > /dev/null
	$SH audit_apps.sh || sequenceAbort

	escapeRoute 'BACKUP'
	crontab -l > $BACKUP/crontab.list
	$SH save_apps.sh
}

function saveData()
{
	$SH data_transfer.sh backup
}

OPERATION=$1

case $OPERATION in
  'final')
		escapeRoute 'BACKUP'
		saveData
    ;;
  *)
		saveButData
		saveData
    ;;
esac


exit 0
