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
  #mongodb
  mtr
  #nvm
  perl
  python3
  #python
  #rtmpdump
  #ruby
  the_silver_searcher
  trash
  vim
  wget
  xz
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
  zsh
  iproute2mac
	#gdbm
	#iftop
	#pcre
	#zsh-completions
)

brew install "${apps[@]}"

brew cleanup

exit 0
