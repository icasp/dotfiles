#!/usr/bin/env bash

if test ! $(which brew)
then
  if test "$(uname)" = "Darwin"
    then echo -e "\n${RED}Brew is not installed or not in PATH${RESET}"
    exit 12
  fi
fi

exit 0
