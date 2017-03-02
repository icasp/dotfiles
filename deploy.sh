#!/bin/bash

DOTSRC=$([[ $0 == /* ]] && dirname $0 || dirname "$(pwd)/$0")
BKDIR="$HOME/.dotfilesbackup"
#DRYRUN=1
TMPLOG='/tmp/dotfiles.log'
test -f $TMPLOG && rm $TMPLOG

RSYNCBIN=$(which rsync) || { echo '!!! rsync not found but required' ; exit 12; }
RSYNCOPTS='-av'
RSYNC_EXCLUDE=("--exclude '.git*'")
if (($DRYRUN)); then RSYNCOPTS='-n '$RSYNCOPTS;fi

function sedInit()
{
	if [ $(uname | tr " " "-") = "Darwin" ]
	then
		SEDOPT="-E"
		ECHOOPT=""
	 else
		 SEDOPT="-r"
		 ECHOOPT="-ne --"
	 fi
}

function deploycandidates()
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
		test -e $HOME/.$candidate && $RSYNCBIN $RSYNCOPTS $HOME/.$candidate $BKDIR/ >> $TMPLOG 2>&1 \
		 && echo "$candidate backup OK" || { ERR=1 ; echo "BACKUP FAILED for $candidate"; }
	done
}

function linkCandidates()
{
	for candidate in $@
	do
		files=$(find $DOTSRC -type f -path "*/$candidate/*" -a -not -path "*.alt*")
		if [ ${#files} -ne 0 ];
		then
			for file in $files
			do
				fileHomePath=$(echo $file | sed $SEDOPT "s@$DOTSRC@$HOME@" | sed $SEDOPT "s@($candidate)@.\1@")
				fileHomeDir=$(echo $fileHomePath | sed $SEDOPT 's@/[^/]+$@@')
				test -e $fileHomeDir || mkdir -p $fileHomeDir
				test -f $fileHomePath && rm $fileHomePath ; ln -s $fileHomePath $file
			done
		else
			test -f $HOME/.$candidate && rm $HOME/.$candidate 2> /dev/null ; ln -s $DOTSRC/$candidate $HOME/.$candidate
		fi
	done
}

function deployAltCandidates()
{
	ALTDOTCANDIDATES=$(cat $DOTSRC/.altcandidates.conf)
	if [[ $1 == 'icasp' ]]; then deploycandidates $ALTDOTCANDIDATES; fi
}

function update()
{
	DOTCANDIDATES=$(cat $DOTSRC/candidates.conf)
	backupCandidates $DOTCANDIDATES
	linkCandidates $DOTCANDIDATES
}

function init()
{
	sh $DOTSRC/install.sh
	update
}

sedInit

case $1 in
	"update")
		update
		;;
	"init")
		init
		;;
	*)
		echo "Please specify update or init (no previous deploys on this system) as deploy method"
		exit 1
	;;
esac
