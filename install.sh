#!/bin/bash

set -e

INSTALL_DIR="setup"

cd "${INSTALL_DIR}"

if [ $(uname | tr " " "-") = "Darwin" ]
then
	sh xcode.sh
	sh homebrew.sh
#	sh formulas.sh
	sh casks.sh
	sh node.sh
	sh macossettings.sh
fi
