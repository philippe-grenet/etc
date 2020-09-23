# Snippets for .zshrc (this is not the complete file)

################################################################################
# Emacs
################################################################################

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e
export EDITOR=/Applications/Emacs-mac.app/Contents/MacOS/Emacs
export GIT_EDITOR=/Applications/Emacs-mac.app/Contents/MacOS/Emacs

# C-x C-e to edit the command line in Emacs
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

################################################################################
# Settings
################################################################################

# Keep 10K lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
# APPEND_HISTORY -> zsh sessions will append their history list to the history
# file, rather than replace it. Thus, multiple parallel zsh sessions will all
# have the new entries from their history lists added to the history file, in
# the order that they exit. The file will still be periodically re-written to
# trim it when the number of lines grows 20% beyond the value specified by
# $SAVEHIST (see also the HIST SAVE BY COPY option).
setopt APPEND_HISTORY
#setopt histignorealldups sharehistory

# Use modern completion system
autoload -Uz compinit && compinit -u

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
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ZLE emacs-like key bindings (meta arrow)
bindkey "^[[5D" backward-word
bindkey "^[[5C" forward-word

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

# GCC colors
export GCC_COLORS='error=01;31:warning=01;33:note=01;36:caret=01;32:locus=01:quote=01'

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
# Prompt
################################################################################

setopt prompt_subst
autoload -U colors && colors

# Colors for prompt
# See http://stackoverflow.com/questions/15682537/ansi-color-specific-rgb-sequence-bash
# and http://misc.flogisoft.com/bash/tip_colors_and_formatting
BLACK=$'\033[0m'
RED=$'\033[38;5;167m'
GREEN=$'\033[38;5;148m'
BLUE=$'\033[38;5;117m'
DARK_BLUE=$'\033[38;5;4m'
YELLOW=$'\033[38;5;221m'
ORANGE=$'\033[38;5;173m'
MAGENTA=$'\033[38;5;105m'

git_branch() {
    git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/\(.*\)/(\1)/g'
}

git_info() {
  # Exit if not inside a Git repository
  ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 && return

  local MODIFIED="$RED●%{$reset_color%}"
  local UNTRACKED="$YELLOW●%{$reset_color%}"
  local STAGED="$GREEN●%{$reset_color%}"
  local -a FLAGS
  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"

  if ! git diff --cached --quiet 2> /dev/null; then
    FLAGS+=( "$STAGED" )
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    FLAGS+=( "$UNTRACKED" )
  fi

  if ! git diff --quiet 2> /dev/null; then
    FLAGS+=( "$MODIFIED" )
  fi

  local -a GIT_INFO
  GIT_INFO+=( "" )
  [ -n "$GIT_STATUS" ] && GIT_INFO+=( "$GIT_STATUS" )
  [[ ${#FLAGS[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)FLAGS}" )
  echo "${(j: :)GIT_INFO}"
}

current_directory() {
    local MACHINE=""
    if [ -n "$SSH_CLIENT" ]; then
        MACHINE="%{$MAGENTA%}%m "
    fi
    local PROMPT_PATH=""
    local CURRENT=`dirname ${PWD}`
    if [[ $CURRENT = / ]]; then
        PROMPT_PATH=""
    elif [[ $PWD = $HOME ]]; then
        PROMPT_PATH=""
    else
        local GIT_REPO_PATH=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ -d $GIT_REPO_PATH ]]; then
            # We are in a git repo. Display the root in color, then the path
            # starting from the root.
            if [[ $PWD -ef $GIT_REPO_PATH ]]; then
                # We are at the root of the git repo.
                PROMPT_PATH=""
            else
                # We are not at the root of the git repo.
                BASE=$(basename $GIT_REPO_PATH)
                GIT_ROOT="%{$fg_bold[red]%}%{$DARK_BLUE%}${BASE}%{$reset_color%}"
                REAL_PWD=$PWD:A
                PATH_TO_CURRENT="${REAL_PWD#$GIT_REPO_PATH}"
                PATH_TO_CURRENT="%{$BLUE%}${PATH_TO_CURRENT%/*}%{$reset_color%}"
                PROMPT_PATH="${GIT_ROOT}${PATH_TO_CURRENT}/"
            fi
        else
            # We are not in a git repo.
            PATH_TO_CURRENT=$(print -P %3~)
            PATH_TO_CURRENT="%{$BLUE%}${PATH_TO_CURRENT%/*}%{$reset_color%}"
            PROMPT_PATH="${PATH_TO_CURRENT}/"
        fi
    fi
    echo "${MACHINE}${PROMPT_PATH}%{$reset_color%}%{$fg_bold[red]%}%{$BLUE%}%1~%{$reset_color%}"
}

export PROMPT=$'$(current_directory) %{$GREEN%}$(git_branch)$(git_info)%{$BLUE%}❯ %{$reset_color%}'
