# -*- mode: sh -*-
# Prompt for zsh

setopt prompt_subst
autoload -U colors && colors

# Colors for the Tomorrow Night theme
# See http://stackoverflow.com/questions/15682537/ansi-color-specific-rgb-sequence-bash
# and http://misc.flogisoft.com/bash/tip_colors_and_formatting
#
# There are 226 (6^3) colors. Taking apart a code like \033[38;5;208m :
# - \033 is the escape code
# - [38; directs command to the foreground. use [48; to change the background instead
# - 5; is just a piece of the sequence that changes color.
# - The most important part, 208m, selects the actual color.
#
# The %{...%} means that the content will be interpreted as a literal escape
# sequence, so the cursor wont move while printing the sequence. If you don't
# use this, the color codes can actually move the cursor and produce undesired
# effects.

BLACK=$'\033[0m'
RED=$'\033[38;5;167m'
GREEN=$'\033[38;5;148m'
GRAY=$'\033[38;5;246m'
BLUE=$'\033[38;5;117m'
DARK_BLUE=$'\033[38;5;4m'
PURPLE=$'\033[38;5;133m'
YELLOW=$'\033[38;5;221m'
ORANGE=$'\033[38;5;173m'
MAGENTA=$'\033[38;5;105m'

path_color="%{$BLUE%}"
highlight_color="%{$fg_bold[red]$BLUE%}"
repo_color="%{$fg_bold[red]$GREEN%}"
branch_color="%{$GRAY%}"
modified_color="%{$RED%}"
untracked_color="%{$YELLOW%}"
staged_color="%{$GREEN%}"
host_color="%{$DARK_BLUE%}"

# Return a colored string containing the name of the git branch in parentheses, like (master).
git_branch() {
    local BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/\(.*\)/on \1/g')
    echo " $branch_color$BRANCH$reset_color"
}

# Return a colored string containing bullets of different colors indicating
# staged/untracked/modified files in a git repo.
git_status() {
    # Populate flags with bullets of different colors for staged/untracked/modified files
    local MODIFIED="$modified_color●$reset_color"
    local UNTRACKED="$untracked_color●$reset_color"
    local STAGED="$staged_color●$reset_color"
    local -a FLAGS

    if ! git diff --cached --quiet 2> /dev/null; then
        FLAGS+=( "$STAGED" )
    fi

    if [[ -n $(git ls-files --other --exclude-standard `git rev-parse --show-toplevel` 2> /dev/null) ]]; then
        FLAGS+=( "$UNTRACKED" )
    fi

    if ! git diff --quiet 2> /dev/null; then
        FLAGS+=( "$MODIFIED" )
    fi

    # Format flags to add a space if not empty
    local -a STATUS
    STATUS+=( "" )
    [[ ${#FLAGS[@]} -ne 0 ]] && STATUS+=( "${(j::)FLAGS}" )
    echo "${(j: :)STATUS}"
}

# If in a git repo, return git_branch() and git_status().
# Otherwise return nothing.
prompt_git_info() {
    # Exit if not inside a Git repository
    ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 && return
    echo "$(git_branch)$(git_status)"
}

# Return a colored string containing the path, shortened to the last 3 directories.
# The current directory is highlighted.
# If in a git repo, the string starts at the root of the repo, highlighted in different color.
prompt_path() {
    local PROMPT_PATH=""
    local CURRENT=$(basename $PWD)
    if [[ $CURRENT = / ]]; then
        PROMPT_PATH="$highlight_color/$reset_color"
    elif [[ $PWD = $HOME ]]; then
        PROMPT_PATH="$highlight_color~$reset_color"
    else
        local GIT_REPO_PATH=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ -d $GIT_REPO_PATH ]]; then
            # Inside a git repo.
            ROOT=$(basename $GIT_REPO_PATH)  # repo name

            if [[ $PWD -ef $GIT_REPO_PATH ]]; then
                # At the root of a git repo.
                PROMPT_PATH="$repo_color$ROOT$reset_color/"
            else
                # Below the root of a git repo.
                REAL_PWD=$PWD:A
                PATH_TO_CURRENT="${REAL_PWD#$GIT_REPO_PATH}"  # path from root, without root
                PATH_TO_CURRENT="${PATH_TO_CURRENT%/*}"       # remove last dir

                if [[ -z "$PATH_TO_CURRENT" ]]; then
                    # just one level below root
                    PROMPT_PATH="$repo_color$ROOT$reset_color/$highlight_color$CURRENT$reset_color"
                else
                    # more than one level below root
                    local -a DIRS=(${(s|/|)PATH_TO_CURRENT})  # split string into array using /
                    local LENGTH="${#DIRS[@]}"
                    if [[ $LENGTH -gt 2 ]]; then
                        PATH_TO_CURRENT="/…/$DIRS[$LENGTH-1]/$DIRS[$LENGTH]"
                    fi
                    PROMPT_PATH="$repo_color$ROOT$reset_color$path_color$PATH_TO_CURRENT$reset_color/$highlight_color$CURRENT$reset_color"
                fi
            fi
        else
            # Not in a git repo.
            # Note: this expression checks for 4 elements long: %(4~|true|false)
            PATH_TO_CURRENT=$(print -P "%(4~|…/%3~|%~)")      # shortened pwd
            PATH_TO_CURRENT="${PATH_TO_CURRENT%/*}"           # remove last dir
            PROMPT_PATH="$path_color$PATH_TO_CURRENT$reset_color/$highlight_color$CURRENT$reset_color"
        fi
    fi
    echo "$PROMPT_PATH"
}

# Return a colored string containing the local host name, if ssh.
# Return an empty string otherwise.
remote_hostname() {
    local MACHINE=""
    if [ -n "$SSH_CLIENT" ]; then
        MACHINE="%{$host_color%}%m $reset_color"
    fi
    echo "$MACHINE"
}

export PROMPT=$'$(remote_hostname)$(prompt_path)$(prompt_git_info) $BLUE❯ $reset_color'
