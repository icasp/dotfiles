#!/usr/bin/env bash

if test ! $(which brew)
then
  if test "$(uname)" = "Darwin"
    then echo "!! Brew is not installed or not in PATH"
    exit 12
  fi
fi

exit 0
