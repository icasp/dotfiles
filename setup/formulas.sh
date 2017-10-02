#!/usr/bin/env bash

output='../logs/formulas.log'
(($LIVEDUMP)) || echo -e "\n##### Starting operation $(date)\n" >> $output 2>&1

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

# Ready for background task with (...) >> $output 2>&1 & except for password input on dependency, maybe later
brew install "${apps[@]}" >> $output 2>&1

brew cleanup

exit 0
