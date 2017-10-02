#!/usr/bin/env bash

output='../logs/casks.log'
(($LIVEDUMP)) || echo -e "\n##### Starting operation $(date)\n" >> $output 2>&1

echo "Installing Homebrew-Cask."

echo -e '\033[1mPress "y" to installs casks, otherwise will skip in 10 seconds...\033[0m'
for i in $(seq 10 1)
do
  read -p $i... -n 1 -t 1 a && break
done
if [[ ! -z $a ]] && [ $a == "y" ]
then
  echo -e "\nLet's go"
else
  echo -e "\n!!Not proceeding with casks installation, next time maybe?"
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

# Ready for background task with (...) >> $output 2>&1 & except for password input on dependency, maybe later
( brew cask install "${apps[@]}" ; \
  echo "Installing Quick Look plugins." ; \
  brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlimagesize qlvideo \
  ) >> $output 2>&1

exit 0
