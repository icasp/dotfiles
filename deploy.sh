#!/bin/bash

DOTSRC=$([[ $0 == /* ]] && dirname $0 || dirname "$(pwd)/$0" | sed 's/\.$//')
BKDIR="$HOME/.dotfilesbackup"

#DRYRUN=1

DOTCANDIDATES=$(cat $DOTSRC/candidates.conf | sed 's/\r$//')
ALTDOTCANDIDATES=$(cat $DOTSRC/.altcandidates.conf | sed 's/\r$//')
ME='icasp'

function envInit()
{
	TMPLOG='/tmp/dotfiles.log'
	test -f $TMPLOG && rm $TMPLOG
	if [ $(uname | tr " " "-") = "Darwin" ]
	then
		SEDOPT="-E"
		ECHOOPT=""
		function hashNow() { md5 -q $1 | cut -d ' ' -f 1; }
	 else
		 SEDOPT="-r"
		 ECHOOPT="-ne --"
		 function hashNow() { md5sum $1 | cut -d ' ' -f 1; }
	 fi

	 	$(uname | grep -q 'NT') && return 0
	 	RSYNCBIN=$(which rsync) || { echo '!!! rsync not found but required' ; exit 12; }
	 	RSYNCOPTS='-av'
	 	RSYNC_EXCLUDE=("--exclude '.git*'")
	 	if (($DRYRUN)); then RSYNCOPTS='-n '$RSYNCOPTS;fi
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
	if [[ $1 == $ME ]]; then deploycandidates $ALTDOTCANDIDATES; fi
}

function compare()
{
	dotHash=$(hashNow $HOME/.$1)
	refHash=$(hashNow $DOTSRC/$2/$1)
	[[ $dotHash == $refHash ]] && echo $dotHash $refHash && continue || \
		echo "## Diffs on $1 go as follows (reference is git): "
	diff --color=always $DOTSRC/$2/$1 $HOME/.$1
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
		subCandidates=$(find $HOME/.$candidate | grep -iv 'ignore')
		for subC in $subCandidates
		do
			test -f $HOME/.$subCandidate && compare $candidate $alt
		done
	done
}

function update()
{
	backupCandidates $DOTCANDIDATES
	linkCandidates $DOTCANDIDATES
}

function init()
{
	sh $DOTSRC/install.sh
	update
}

function audit()
{
	auditCandidates $DOTCANDIDATES
	auditCandidates $ALTDOTCANDIDATES '.alt'
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
		echo "Please specify update or init (no previous deploys on this system) as deploy method"
		exit 1
	;;
esac
