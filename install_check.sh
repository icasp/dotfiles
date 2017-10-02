#!/usr/bin/env bash

sPath=$([[ $0 == /* ]] && dirname $0 || dirname "$(pwd)/$0")
(($COREINIT)) || source $sPath/core.source || { echo -e "\n\033[31m!! Could not find 'core.source' in parent folder??\n\033[m" && exit 12; }
cd $DOTSRC > /dev/null

SH='sh'
which bash &> /dev/null && SH=$(which bash)

INSTALL_DIR="checklist"
cd "${INSTALL_DIR}"

if [ ! -z $1 ]
then
  test -e $1_check.sh && $SH $1_check.sh || $SH -c "echo -e \"\033[31m$1.sh\033[m does not exist or failed, exiting...\"" && exit 12
fi

if [ $(uname | tr " " "-") = "Darwin" ]
then
	#$SH xcode_check.sh
	$SH homebrew_check.sh
	if [ $? -eq 0 ]
  then
    $SH formulas_check.sh
	  $SH casks_check.sh
  else
    echo "Not checking formulas & casks, check again after fixing previous error"
  fi
	#$SH node_check.sh
	$SH macossettings_check.sh
fi

exit 0
