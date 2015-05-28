# Philippe's .zshrc

################################################################################
# Path
################################################################################

# export MANPATH="/usr/local/man:$MANPATH"

path=(/opt/local/libexec/gnubin $path)
path=(/opt/local/bin $path)
path=(/Users/phi/bin $path)

################################################################################
# Emacs
################################################################################

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e
export EDITOR=/Applications/Emacs.app/Contents/MacOS/Emacs
export GIT_EDITOR=/Applications/Emacs.app/Contents/MacOS/Emacs

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history
#setop INC_APPEND_HISTORY
setopt APPEND_HISTORY

################################################################################
# Settings
################################################################################

#setopt histignorealldups sharehistory

# Set up the prompt
autoload -Uz promptinit
promptinit

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ZLE emacs-like key bindings (meta arrow)
bindkey "^[[5D" backward-word
bindkey "^[[5C" forward-word

# Type directory name to cd, and automatic pushd every time you cd
setopt autocd autopushd

################################################################################
# Colors
################################################################################

# ls
alias ls="ls --color=auto"
alias la="ls -a"
alias ll="ls -l"

# Terminal colors
export TERM=xterm-256color

# stderr in color ("\e[91m${X}\e[0m" for no bold)
#exec 2>>( while read X; do print "\e[91;1m${X}\e[0m" > /dev/tty; done & )

# Grep in color
export GREP_OPTIONS='--color=always'
export GREP_COLOR='1;31'

################################################################################
# Prompt
################################################################################

autoload -U colors && colors
#export PROMPT="%{$fg_bold[green]%}[%m:%{$fg_bold[cyan]%}%3~%{$fg_bold[green]%}]$%{$reset_color%} "

parse_git_branch () {
    git branch 2> /dev/null | grep "*" | sed -e 's/* \(.*\)/(\1)/g'
}

current_git_branch() {
    git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/\(.*\)/(\1)/g'
}

# Colors for prompt
# See http://stackoverflow.com/questions/15682537/ansi-color-specific-rgb-sequence-bash
# and http://misc.flogisoft.com/bash/tip_colors_and_formatting
BLACK=$'\033[0m'
RED=$'\033[38;5;167m'
#GREEN=$'\033[38;5;71m'
GREEN=$'\033[38;5;148m'
#BLUE=$'\033[38;5;111m'
BLUE=$'\033[38;5;117m'
#YELLOW=$'\033[38;5;228m'
YELLOW=$'\033[38;5;221m'
ORANGE=$'\033[38;5;173m'

function precmd() {
    #export PROMPT="%{$BLUE%}%m%{$GREEN%}[%3~]%{$YELLOW%}$(parse_git_branch)%{$BLACK%}%# "
    export PROMPT="%{$BLUE%}%m%{$GREEN%}[%3~]%{$YELLOW%}$(current_git_branch)%{$BLACK%}%# "
    case $TERM in
        xterm*)
            print -Pn "\e]0;%n@%m: %~\a"
            ;;
    esac
}

################################################################################
# Functions
################################################################################

fpath=(~/.zsh/fn $fpath)

for file in ${HOME}/.zsh/fn/*; do
    if [ -f ${file} ]; then
        source ${file}
    fi
done

################################################################################
# Aliases
################################################################################

alias epurge="/bin/rm -f ?*~ .?*~"
alias batt='ioreg -l | grep Capacity'
alias ec='/Applications/Emacs.app/Contents/MacOS/Emacs'
alias emnw='/Applications/Emacs.app/Contents/MacOS/Emacs -nw'
alias vlc='/Applications/VLC.app/Contents/MacOS/VLC'
alias cls='echo -e "\ec\e[3J"'
