# Prompt for zsh

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
