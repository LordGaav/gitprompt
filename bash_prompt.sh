#!/usr/bin/env bash

# if $TERM is not set, we cannot use colors and other features
# I observed that this happens during SCP/SFTP, we should just
# stop processing in those cases
if [ -z "$TERM" ]; then
	return;
fi

## set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

parse_svn_branch() {
        parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk -F / '{print "svn::"$1 "/" $2 }'
}
parse_svn_url() {
        svn info 2>/dev/null | grep -e '^URL*' | sed -e 's#^URL: *\(.*\)#\1#g '
}
parse_svn_repository_root() {
        svn info 2>/dev/null | grep -e '^Repository Root:*' | sed -e 's#^Repository Root: *\(.*\)#\1\/#g '
}

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
NORMAL=$(tput sgr0)

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto verbose"

if [ "$color_prompt" = yes ]; then
		PS1='\[${NORMAL}\]${debian_chroot:+($debian_chroot)}\u@\h\[${CYAN}\] \w \[${RED}\]$(__git_ps1 "git::%s")$(parse_svn_branch) \[${WHITE}\]$\[${NORMAL}\] '
else
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
		echo
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w \$(__git_ps1 'git::%s')\$(parse_svn_branch)  \a\]$PS1"
    ;;
*)
    ;;
esac
