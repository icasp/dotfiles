#!/usr/bin/env bash

sPath=$([[ $0 == /* ]] && dirname $0 || dirname "$(pwd)/$0")
source $sPath/../core.source || { echo -e "\n\033[31m!! Could not find 'core.source' in parent folder??\n\033[m" && exit 12; }

echo "Setting course for $HOME/.dotfiles/mac_reset folder"
rsync -au --delete $BACKUP/dotfiles/ $HOME/.dotfiles/
cd $HOME/.dotfiles/mac_reset
pwd
echo -e "${ORANGEBOLD}.dotfiles folder ready to go, the bridge is yours captain!${RESET}"
