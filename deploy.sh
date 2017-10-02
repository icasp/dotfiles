#!/usr/bin/env bash

sPath=$([[ $0 == /* ]] && dirname $0 || dirname "$(pwd)/$0")
(($COREINIT)) || source $sPath/core.source || { echo -e "\n\033[31m!! Could not find 'core.source' in parent folder??\n\033[m" && exit 12; }
cd $DOTSRC > /dev/null
BKDIR="$HOME/.dotfilesbackup"
#DRYRUN=1

DOTCANDIDATES=$(cat $DOTSRC/candidates.conf | sed 's/\r$//')
ALTDOTCANDIDATES=$(cat $DOTSRC/.altcandidates.conf | sed 's/\r$//')

function deployCandidates()
{
	for candidate in $@
	do
		echo "Deploying $candidate..."
		$RSYNCBIN $RSYNCOPTS $RSYNC_EXCLUDE $DOTSRC/.$candidate $HOME/ >> $TMPLOG 2>&1 \
		 && echo "OK" || { ERR=1 ; echo "FAILED"; }
	done

	if [[ -z $ERR ]] && test -f $TMPLOG; then rm $TMPLOG; else echo "!! Consult $DOTFILES for deployement errors"; fi
}

function backupCandidates()
{
	test -e $BKDIR || mkdir -p $BKDIR
	for candidate in $@;
	do
		test -e $HOME/.$candidate || { echo "$candidate does not exist on source, not backing up (obviously)" ; continue ; }
		$RSYNCBIN $RSYNCOPTS $HOME/.$candidate $BKDIR/ >> $TMPLOG 2>&1 \
		 && echo "$candidate backup OK" || { ERR=1 ; echo "BACKUP FAILED for $candidate"; return 12 ; }
	done
}

function linkCandidates()
{
	for candidate in $@
	do
		files=$(find $DOTSRC -type f -path "*/$candidate/*" -a -not -path "*.alt*" | grep -v 'gitignore')
		dirs=$(find $DOTSRC -type d -path "*/$candidate/*" -a -not -path "*.alt*" | sed $SEDOPT "s@$DOTSRC@$HOME@" | sed $SEDOPT "s@($candidate)@.\1@")
		for dir in $dirs
		do
			mkdir -p "$dir"
		done
		if [ ${#files} -ne 0 ];
		then
			for file in $files
			do
				fileHomePath=$(echo $file | sed $SEDOPT "s@$DOTSRC@$HOME@" | sed $SEDOPT "s@($candidate)@.\1@")
				fileHomeDir=$(echo $fileHomePath | sed $SEDOPT 's@/[^/]+$@@')
				test -e $fileHomeDir || mkdir -p $fileHomeDir
				test -f $fileHomePath && rm $fileHomePath ; ln -s $file $fileHomePath
			done
		else
			test -f $HOME/.$candidate && rm $HOME/.$candidate 2> /dev/null ; ln -s $DOTSRC/$candidate $HOME/.$candidate
		fi
	done
}

function deployAltCandidates()
{
	if [[ $1 == $ME ]]; then deploycandidates $ALTDOTCANDIDATES; fi
}

function compare()
{
	test -f $DOTSRC/$2/$1 || { echo "!! $1 not in dotfiles ref but exists locally" ; continue ; }
	dotHash=$(hashNow $HOME/.$1)
	refHash=$(hashNow $DOTSRC/$2/$1)
	[[ $dotHash == $refHash ]] && echo "$1 OK"  && continue || \
		echo "## Diffs on $1 go as follows (reference is git): "
	git diff $DOTSRC/$2/$1 $HOME/.$1
	echo ''
}

function auditCandidates()
{
	candidates=$@
	#${@:$#}
	[[ ${!#} == '.alt' ]] && alt=${!#} && candidates=${*%${!#}}
	for candidate in $candidates
	do
		test -e $HOME/.$candidate || { echo "!! $candidate is not deployed on this system" ; continue ; }
		test -f $HOME/.$candidate && compare $candidate $alt
		subCandidates=$(find $HOME/.$candidate | grep -iv 'ignore' | sed "s@$HOME/*\.@@g")
		for subC in $subCandidates
		do
			test -f $HOME/.$subC &&  compare $subC $alt
		done
	done
}

function setShell()
{
	currentShell=$(dscl . -read /Users/$ME UserShell | cut -d ' ' -f 2)
	test -f /usr/local/bin/zsh && newShell='/usr/local/bin/zsh' || newShell='/bin/zsh'
	sudo dscl localhost -change Local/Default/Users/$USER UserShell /bin/bash $newShell
	#chsh -s $newShell
}

function preztoNow()
{
	test -e "${ZDOTDIR:-$HOME}/.zprezto" && return 0
  cd $HOME \
    && git clone --recursive https://github.com/icasp/prezto.git "${ZDOTDIR:-$HOME}/.zprezto" \
    && cd "${ZDOTDIR:-$HOME}/.zprezto" \
    && chmod +x install.sh && ./install.sh \
&& echo "PREZTO INSTALLATION SUCCESS" \
    && setShell
  cd $DOTSRC
}

function update()
{
	backupCandidates $DOTCANDIDATES
	linkCandidates $DOTCANDIDATES
preztoNow
}

function init()
{
	update
	sh $DOTSRC/install.sh
}

function audit()
{
	echo -e "${ORANGEBOLD}Now auditing dotfiles candidates...${RESET}"
	auditCandidates $DOTCANDIDATES
	auditCandidates $ALTDOTCANDIDATES '.alt'
	sh $DOTSRC/install_check.sh
}

envInit

case $1 in
	"update")
		update
		;;
	"init")
		init
		;;
	"audit")
		audit
		;;
	*)
		echo "Please specify update, init or audit as deploy method"
		exit 1
	;;
esac
