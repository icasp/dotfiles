#!/usr/bin/env bash

echo "Installing Homebrew-Cask."

echo -e '\033[1mPress "y" to installs casks, otherwise will skip in 10 seconds...\033[0m'
for i in $(seq 10 1)
do
  read -p $i... -n 1 -t 1 a && break
done
if [ $a == "y" ]
then
  echo -e "\nLet's go"
else
  echo -e "\n!!OK, next time maybe?"
  exit 0
fi

brew tap caskroom/cask
brew tap caskroom/versions

apps=(
  #1password
  alfred
  appcleaner
  atom
  #calibre
  couleurs
  discord
  dropbox
  fantastical
  firefox
  gitkraken
  ##google-chrome-canary
  ##google-chrome-dev
  imageoptim
  #istat-menus
  iterm2
  #iterm2-beta
  kaleidoscope
  karabiner-elements
  licecap
  namebench
  onyx
  postman
  #robomongo
  slack
  spectacle
  spotify
  steam
  the-unarchiver
  vlc
  adobe-acrobat-reader
  colloquy
  daisydisk
  dash
  discord
  docker
  evernote
  fantastical
  google-chrome
  omnifocus
  #plex-media-player
  #plex-media-server
  #postbox
  teamviewer
  telegram
  tunnelbear
  whatsapp
  yakyak
)

echo "Installing Casks."

brew cask install "${apps[@]}"

echo "Installing Quick Look plugins."

brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlimagesize qlvideo

exit 0
