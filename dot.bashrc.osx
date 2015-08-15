# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Path
export PATH=~/bin:/opt/local/libexec/gnubin:$PATH
export PATH=/usr/local/git/bin:$PATH

# Prompt
NM="\[\033[0;38m\]" #means no background and white lines
HI="\[\033[0;37m\]" #change this for letter colors
HII="\[\033[0;31m\]" #change this for letter colors
SI="\[\033[0;33m\]" #this is for the current directory
IN="\[\033[0m\]"

C_RED="\[\033[0;31m\]"
C_GREEN="\[\033[0;32m\]"
C_LIGHT_GRAY="\[\033[0;37m\]"
C_BROWN="\[\033[0;33m\]"
C_BLUE="\[\033[0;34m\]"
C_PURPLE="\[\033[0;35m\]"
C_CYAN="\[\033[0;36m\] "
C_GRAY="\[\033[1;30m\]"
C_WHITE="\[\033[1;37m\]"
C_YELLOW="\[\033[1;33m\]"
C_BOLD_BLUE="\[\033[1;34m\]"
C_BOLD_CYAN="\[\033[1;36m\]"
C_BOLD_PURPLE="\[\033[1;35m\]"
C_BOLD_RED="\[\033[1;31m\]"
C_BOLD_GREEN="\[\033[1;32m\]"
C_BOLD="\[\033[1m\]"
C_RESET="\[\033[0m\]"

#export PS1="$NM[ $HI\u $HII\h $SI\W$NM ] $IN"

export MYPS='$(echo -n "${PWD/#$HOME/~}" | awk -F "/" '"'"'{if (length($0) > 14) { if (NF>4) print $1 "/" $2 "/.../" $(NF-1) "/" $NF; else if (NF>3) print $1 "/" $2 "/.../" $NF; else print $1 "/.../" $NF; } else print $0;}'"'"')'

# Don't know why it does not reevaluate MYPS all the time because the very same code works fine on Linux.
# Maybe some bash option?
#export PS1="$C_CYAN[$(eval echo ${MYPS})]$ $C_RESET"
export PS1="$C_CYAN[$C_GREEN\u@\h$C_CYAN \W]$C_RESET "

# Aliases
if [ "$TERM" != "dumb" ]; then
    export LS_OPTIONS='--color=auto'
    eval `dircolors ~/.dir_colors`
fi

alias ls='ls $LS_OPTIONS -hF'
alias ll='ls $LS_OPTIONS -lhF'
alias la='ls $LS_OPTIONS -lAhF'

alias mkdir='mkdir -p -m 755'    # executable
alias mv='mv -i'
alias rm='rm -i'                 # interactive
alias epurge='rm -f .??*~ ??*~'        # emacs backup files
alias first='ls -lt | sed '1d' | head -n '

alias em='open -a /Applications/Emacs.app $1'
alias vlc='/Applications/VLC.app/Contents/MacOS/VLC'

alias cls='echo -e "\ec\e[3J"'

# Mac specific stuff
alias batt='ioreg -l | grep Capacity'

#alias accents='setxkbmap -symbols "en_US(pc105)"'
# Couleurs pour ls
#eval `dircolors -b /etc/DIR_COLORS`

# Git
export GIT_EDITOR=emacs
export GIT_AUTHOR_NAME="Philippe Grenet"
export GIT_AUTHOR_EMAIL="philippe_grenet@yahoo.com"

export GIT_EDITOR=emacs

# stderr in color
color()(set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[1;31m&\e[m,'>&2)3>&1

alias make="color make"
