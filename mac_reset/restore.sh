#!/usr/bin/env bash
sPath=$([[ $0 == /* ]] && dirname $0 || dirname "$(pwd)/$0")
CORE="$sPath/../core.source"
test -e $CORE && source $CORE || { echo -e "\n\033[31m!! Could not find 'core.source' in parent folder??\n\033[m" && exit 12; }

echo $sPath | grep -q $BACKUP \
  && { echo 'Switching context to SYSTEM from backup device' && bash prep_for_restore.sh && bash $HOME/.dotfiles/mac_reset/restore.sh  ; exit $? ; }
cd $sPath > /dev/null

homeArchive="${sPath}/homeBackup.tgz"

echo -e "${ORANGEBOLD}#Initiating restore process${RESET}"

if [ ! $(id -u) -eq "0" ]
then
  homeSize=$(du -hs $HOME | awk -F ' ' '{print $1}')
  echo -e "Backing up Home folder in '$sPath/homeBackup' just in case (size is $homeSize)..."
  rsync -au --exclude '*.dotfiles*' $HOME/ homeBackup/ &> /dev/null
  bash operations/system_setup.sh restore
  rPath=$(pwd)
  cd ..
  $SH setup/xcode.sh
  $SH setup/homebrew.sh && brew install zsh
  $SH deploy.sh update || sequenceAbort
  cd $rPath
  crontab $BACKUP/crontab.list || sequenceAbort
fi

(escapeRoute 'DATA RESTORE' && $SH operations/data_transfer.sh restore)
cd .. && $SH install.sh ; cd $rPath

echo -e "\n${ORANGEBOLD}#### RESTORE END REPORT AND NOTES\n"
echo -e "!! Must be restored manually :"
echo -e "- apps saved with save_apps.sh (in '$BACKUP/apps') and others non brewed (launch operations/audit_apps.sh to know)"

if [ $(id -u) -eq 0 ]
then
  echo -e "\nAnd also because restore was performed as root and not everything was covered in that case"
  test -e $BACKUP/crontab.list && echo -e "- crontabs (in '$BACKUP/crontab.list')"
  echo -e "- dotfiles (with deploy script)"
fi

echo -e "${RESET}"
cd $sPath > /dev/null

echo "Wrapping up and cleaning... just a moment please..."
test -e homeBackup && tar -czf $homeArchive homeBackup && rm -rf homeBackup \
  && echo "Note : Just in case, pre restore operations HOME folder was backed up in $homeArchive" \
  || echo "Note : Backup of HOME folder not found for archiving???"
