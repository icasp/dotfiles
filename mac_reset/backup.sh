#!/usr/bin/env bash
sPath=$([[ $0 == /* ]] && dirname $0 || dirname "$(pwd)/$0")
source $sPath/../core.source || { echo -e "\n\033[31m!! Could not find 'core.source' in parent folder??\n\033[m" && exit 12; }
mkdir -p $sPath'/runtime'

checks=(
  'zprezto repo should be in sync (especially if forked)'
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
	cd ${sPath}/.. && $SH deploy.sh audit || sequenceAbort
	cd $sPath > /dev/null
	$SH operations/audit_apps.sh || sequenceAbort

	escapeRoute 'BACKUP'
	mkdir -p $BACKUP
  test -e runtime && rm -rf runtime/* 2> /dev/null
  bash operations/system_setup.sh backup
	crontab -l > $BACKUP/crontab.list
	$SH operations/save_apps.sh
}

function saveData()
{
	mkdir -p $BACKUP
	$SH operations/data_transfer.sh backup
}

function syncDotFiles()
{
  echo -e "\n${ORANGEBOLD}Syncing dotfiles folder to $BACKUP/dotfiles${RESET}\n"
  rsync -au --delete ../ $BACKUP/dotfiles/
  echo "You're good to go"
}

OPERATION=$1

case $OPERATION in
  'final')
		escapeRoute 'BACKUP'
		saveData
    ;;
  'sync')
    syncDotFiles
    ;;
  *)
		saveButData
		saveData
		syncDotFiles
    ;;
esac

exit 0
