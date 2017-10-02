#!/usr/bin/env bash
sPath=$([[ $0 == /* ]] && dirname $0 || dirname "$(pwd)/$0")
ENVERR="\033[31m!! Environment not initialized, if calling child script then use 'bash -c \"source [../]core.source && bash $0\"'\033[m"
(($COREINIT)) || { echo -e $ENVERR && exit 12 ; }

PREFS=$DOTSRC'/mac_reset/runtime/systemsetup.prefs'
FILEPREFS=$DOTSRC'/mac_reset/runtime/filesharing.prefs'

function saveSetup()
{
  test -f $PREFS && rm -f $PREFS
  hostname -f >> $PREFS
  sudo systemsetup -getcomputername >> $PREFS
  sudo systemsetup -getremotelogin >> $PREFS
  #[[ -f /etc/com.apple.screensharing.agent.launchd ]] && echo 'enabled' || echo 'disabled'
  [[ -f /etc/RemoteManagement.launchd ]] && echo 'enabled' >> $PREFS || echo 'disabled' >> $PREFS
  sudo launchctl list | grep -q afp && echo 'enabled' >> $PREFS || echo 'disabled' >> $PREFS
  sudo launchctl list | grep -q smb && echo 'enabled' >> $PREFS || echo 'disabled' >> $PREFS
  sudo sharing -l >> $FILEPREFS
}

function getValues()
{
  test -f $PREFS || exit 21
  fQDN=$(getLineFromFile 1 $PREFS)
  computerName=$(getLineFromFile 2 $PREFS | awk -F ': ' '{print $2}')
  ssh=$(getLineFromFile 3 $PREFS | awk -F ': ' '{print $2}')
  remote=$(getLineFromFile 4 $PREFS [ tr '[A-Z]' '[a-z]')
  afp=$(getLineFromFile 5 $PREFS)
  smb=$(getLineFromFile 6 $PREFS)
}

function restoreSetup()
{
  sudo scutil --set HostName $fQDN
  sudo systemsetup -setcomputername "$computerName"
  sudo systemsetup -setremotelogin $ssh
  if [[ ! -z $remote ]] && [[ $remote == 'enabled' ]]
  then
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -allowAccessFor -allUsers -privs -all -clientopts -setmenuextra -menuextra yes
    #sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -allowAccessFor -specifiedUsers
    #sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -users teacher,student -access -on -privs -ControlObserve -ObserveOnly -TextMessages
  fi
  if [[ ! -z $afp ]] && [[ $afp == 'enabled' ]]
  then
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist
  fi
  if [[ ! -z $smb ]] && [[ $smb == 'enabled' ]]
  then
    sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.smbd.plist
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist EnabledServices -array disk
  fi
}

function informMissing()
{
  echo -e "The following was not automatically deployed :\n\
    - Shares configuration, stored in $FILEPREFS"
}

OPERATION=$1

case $OPERATION in
  'backup')
    saveSetup
    ;;
  'restore')
    getValues && restoreSetup && informMissing
    ;;
  *)
    failedArgs "'backup' or 'restore'"
    ;;
esac
