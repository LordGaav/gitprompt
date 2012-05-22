#!/usr/bin/env bash
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

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
LIME_YELLOW=$(tput setaf 190)
YELLOW=$(tput setaf 3)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

parse_git_branch() {
        if git rev-parse --git-dir >/dev/null 2>&1
        then
                gitver=$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')
                if [ "$1" = "colorless" ]
                then
                        gitver='git::'$gitver
                else
                        if git diff --quiet 2>/dev/null >&2
                        then
                                gitver=${GREEN}'git::'$gitver${NORMAL}
                        else
                                gitver=${RED}'git::'$gitver${NORMAL}
                        fi
                fi
        else
               return 0
        fi
        echo -e $gitver
}
parse_svn_branch() {
        parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk -F / '{print "svn::"$1 "/" $2 }'
}
parse_svn_url() {
        svn info 2>/dev/null | grep -e '^URL*' | sed -e 's#^URL: *\(.*\)#\1#g '
}
parse_svn_repository_root() {
        svn info 2>/dev/null | grep -e '^Repository Root:*' | sed -e 's#^Repository Root: *\(.*\)#\1\/#g '
}

if [ "$color_prompt" = yes ]; then
        PS1="\[${NORMAL}\]\u@\h\[${CYAN}\] \w \[${RED}\]\$(parse_git_branch)\$(parse_svn_branch) \[${WHITE}\]$\[$NORMAL\] "
else
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w \$(parse_git_branch colorless)\$(parse_svn_branch)  \a\]$PS1"
    ;;
*)
    ;;
esac
