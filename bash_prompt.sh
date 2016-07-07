#!/usr/bin/env bash

# if $TERM is not set, we cannot use colors and other features
# I observed that this happens during SCP/SFTP, we should just
# stop processing in those cases
if [ -z "$TERM" ]; then
	return;
fi

echo "$SHELL" | grep -q bash
IS_BASH=$?

# this prompt only works properly for bash, so lets just exit if we are
# running something else
if [ $IS_BASH -ne 0 ]; then
	return;
fi

## set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Set to yes to enable colors in the prompt
enable_color_prompt=yes

if [ -n "$enable_color_prompt" ]; then
	if [ "$TERM" = "cygwin" ]; then
		# Cygwin's Bash is lacking the tput commando, so we should use the
		# raw ANSI escape values
		color_prompt=yes
		RED=$(echo -e '\033[0;31m')
		GREEN=$(echo -e '\033[0;32m')
		CYAN=$(echo -e '\033[0;36m')
		WHITE=$(echo -e '\033[1;37m')
		NORMAL=$(echo -e '\033[0m')
    elif [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
		RED=$(tput setaf 1)
		GREEN=$(tput setaf 2)
		CYAN=$(tput setaf 6)
		WHITE=$(tput setaf 7)
		NORMAL=$(tput sgr0)
    else
        color_prompt=
    fi
fi

parse_svn_branch() {
	SVN_URL=$(parse_svn_url)
	if [ -z "$SVN_URL" ]; then return; fi
	echo "$SVN_URL" | awk -F / '{print "'$(parse_svn_proto)'::" $(NF-1) "/" $NF}'
}
parse_svn_proto() {
	parse_svn_url | awk -F : '{print $1}' | sed -e 's#\(http\|https\)#svn#g'
}
parse_svn_url() {
    svn info 2>/dev/null | grep -e '^URL*' | sed -e 's#^URL: *\(.*\)#\1#g '
}

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto verbose"

if [ "$color_prompt" = yes ]; then
		PS1='\[${NORMAL}\]${debian_chroot:+($debian_chroot)}\u@\h\[${CYAN}\] \w \[${RED}\]$(__git_ps1 "git::%s")\[${GREEN}\]$(parse_svn_branch) \[${WHITE}\]\$\[${NORMAL}\] '
else
		PS1='${debian_chroot:+($debian_chroot)}\u@\h \w $(__git_ps1 "git::%s")$(parse_svn_branch) \$ '
fi

# If this is an xterm set the title as well
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w \$(__git_ps1 'git::%s')\$(parse_svn_branch)  \a\]$PS1"
    ;;
*)
    ;;
esac
unset color_prompt enable_color_prompt
