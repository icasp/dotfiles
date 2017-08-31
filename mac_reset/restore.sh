#!/usr/bin/env bash

test -e globals.sh && source globals.sh || { echo -e "\n\033[31m!! Please execute scripts from project folder\n\033[m" && exit 12; }

if [ ! $(id -u) -eq "0" ]
then
  $SH ../deploy.sh restore || sequenceAbort
  $SH ../install.sh || sequenceAbort
  crontab $BACKUP/crontab.list || sequenceAbort
fi

(escapeRoute 'DATA RESTORE' && $SH data_transfer.sh restore)

echo -e "\n${ORANGEBOLD}#### RESTORE END REPORT AND NOTES\n"
echo -e "!! Must be restored manually :"
echo -e "- apps saved with save_apps.sh (in '$BACKUP/apps')"
#echo -e "- "

if [ ! $(id -u) -eq 0 ]
then
  echo -e "\nAnd also because restore was performed as root and not everything was covered in that case"
  test -e $BACKUP/crontab.list && echo -e "- crontabs (in '$BACKUP/crontab.list')"
  echo -e "- zprezto clone"
  echo -e "- dotfiles (with deploy script)"
fi
echo -e "${RESET}"
