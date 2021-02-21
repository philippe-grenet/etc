# -*- mode: sh -*-
# Prompt for zsh
# See https://scriptingosx.com/2019/07/moving-to-zsh-06-customizing-the-zsh-prompt/

setopt prompt_subst
autoload -U colors && colors

# Colors for the Tomorrow Night theme
# xterm-256color codes: https://jonasjacek.github.io/colors/
color_path='117'      # SkyBlue1
color_repo='148'      # Yellow3
color_branch='246'    # Gray58
color_modified='167'  # IndianRed
color_untracked='221' # LightGoldenrod2
color_staged='148'    # Yellow3
color_host='93'       # Purple

# Return a colored string containing the name of the git branch in parentheses, like (master).
git_branch() {
    local BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/\(.*\)/on \1/g')
    echo " %F{$color_branch}$BRANCH%f"
}

# Return a colored string containing bullets of different colors indicating
# staged/untracked/modified files in a git repo.
git_status() {
    # Populate flags with bullets of different colors for staged/untracked/modified files
    local MODIFIED="%F{$color_modified}●%f"
    local UNTRACKED="%F{$color_untracked}●%f"
    local STAGED="%F{$color_staged}●%f"
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
        # At /
        PROMPT_PATH="%F{$color_path}/%f"
    elif [[ $PWD = $HOME ]]; then
        # At ~
        PROMPT_PATH="%F{$color_path}~%f"
    else
        local GIT_REPO_PATH=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ -d $GIT_REPO_PATH ]]; then
            # Inside a git repo.
            ROOT=$(basename $GIT_REPO_PATH)  # repo name

            if [[ $PWD -ef $GIT_REPO_PATH ]]; then
                # At the root of the repo.
                PROMPT_PATH="%B%F{$color_repo}$ROOT%f%b"
            else
                # Below the root of the repo.
                REAL_PWD=$PWD:A
                PATH_TO_CURRENT="${REAL_PWD#$GIT_REPO_PATH}"  # path from root, without root
                PATH_TO_CURRENT="${PATH_TO_CURRENT%/*}"       # remove last dir

                if [[ -z "$PATH_TO_CURRENT" ]]; then
                    # Just one level below root
                    PROMPT_PATH="%F{$color_repo}$ROOT/%f%B%F{$color_path}$CURRENT%f%b"
                else
                    # More than one level below root
                    local -a DIRS=(${(s|/|)PATH_TO_CURRENT})  # split string into array using /
                    local LENGTH="${#DIRS[@]}"
                    if [[ $LENGTH -gt 2 ]]; then
                        PATH_TO_CURRENT="/…/$DIRS[$LENGTH-1]/$DIRS[$LENGTH]"
                    fi
                    PROMPT_PATH="%F{$color_repo}$ROOT%f%F{$color_path}$PATH_TO_CURRENT/%B$CURRENT%b%f"
                fi
            fi
        else
            # Not in a git repo.
            # Note: this expression checks for 4 elements long: %(4~|true|false)
            PATH_TO_CURRENT=$(print -P "%(4~|…/%3~|%~)")      # shortened pwd
            PATH_TO_CURRENT="${PATH_TO_CURRENT%/*}"           # remove last dir
            PROMPT_PATH="%F{$color_path}$PATH_TO_CURRENT/%B$CURRENT%b%f"
        fi
    fi
    echo "$PROMPT_PATH"
}

# Return a colored string containing the local host name, if ssh.
# Return an empty string otherwise.
remote_hostname() {
    local MACHINE=""
    if [ -n "$SSH_CLIENT" ]; then
        MACHINE="%F{$color_host}[%m]%f "
    fi
    echo "$MACHINE"
}

export PROMPT=$'$(remote_hostname)$(prompt_path)$(prompt_git_info) %F{$color_path}❯ %f'

# Simple/uncolored prompt for troubleshooting
noprompt() {
    export PROMPT='%2~ ❯ '
}
