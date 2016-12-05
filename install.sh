#!/bin/bash

DOTSRC=$([[ $0 == /* ]] && dirname $0 || dirname "$(pwd)/$0")
#DRYRUN=1
TMPLOG='/tmp/dotfiles.log'
test -f $TMPLOG && rm $TMPLOG

RSYNCBIN=$(which rsync) || { echo '!!! rsync not found but required' ; exit 12; }
RSYNCOPTS='-av'
RSYNC_EXCLUDE=("--exclude '.git*'")
if (($DRYRUN)); then RSYNCOPTS='-n '$RSYNCOPTS;fi

function deploycandidates()
{
	for candidate in $@;
	do
		echo "Deploying $candidate..."
		$RSYNCBIN $RSYNCOPTS $RSYNC_EXCLUDE $DOTSRC/.$candidate $HOME/ >> $TMPLOG 2>&1 \
		 && echo "OK" || { ERR=1 ; echo "FAILED"; }
	done

	if [[ -z $ERR ]] && test -f $TMPLOG; then rm $TMPLOG; else echo "!! Consult $DOTFILES for deployement errors"; fi
}

DOTCANDIDATES='vim vimrc editorconfig screenrc.d curlrc'
ALTDOTCANDIDATES='aws docker gitconfig livestreamerrc'

deploycandidates $DOTCANDIDATES
if [[ $1 == 'icasp' ]]; then deploycandidates $ALTDOTCANDIDATES; fi
