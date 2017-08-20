#!/usr/bin/env bash

echo "Installing Formulas"

brew tap homebrew/dupes

apps=(
  ctags
  streamlink
  git
  git-extras
  homebrew/completions/brew-cask-completion
  htop
  mongodb
  mtr
  nvm
  perl
  python
  rtmpdump
  ruby
  the_silver_searcher
  trash
  vim
  wget
  xz
  zsh
  pdfgrep
  watch
  tldr
  nmap
  fortune
  p7zip
  unrar
  highlight
  testdisk
  wakeonlan
  iperf
  netcat
  dos2unix
)

brew install "${apps[@]}"

brew cleanup

exit 0
