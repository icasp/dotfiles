#!/usr/bin/env bash
set -e

SH='sh'
which bash &> /dev/null && SH=$(which bash)
INSTALL_DIR="setup"
logFile='../logs/formulas.log'
cd "${INSTALL_DIR}"

if [ ! -z $1 ]
then
  test -e $1.sh && $SH $1.sh || $SH -c "echo -e \"\033[31m$1.sh\033[m does not exist or failed, exiting...\"" && exit 12
fi

if [ $(uname | tr " " "-") = "Darwin" ]
then
	sh xcode.sh
	sh homebrew.sh \
		&& echo "Will now install formulas in the background, progress can be followed in ${INSTALL_DIR}/$logFile" \
		&& (sh formulas.sh &> $logFile &)
	$SH casks.sh
	$SH python.sh && $SH pip.sh
	#sh node.sh
	sh macossettings.sh
fi
