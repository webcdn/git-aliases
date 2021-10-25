#!/usr/bin/env bash
# Git Aliases

{ # this ensures the entire script is downloaded #

# helpers
# ----------------------------------------------------------------------------------
git_echo() {
    command printf %s\\n "$*" 2>/dev/null
}

git_detect_remote() {
    if [[ -z "$1" ]]; then
        _ORIGIN="$(git remote)"
        git_echo "::: Detected Remote: $_ORIGIN"
    else
        _ORIGIN="$1"
        git_echo "::: Requested Remote: $_ORIGIN"
    fi

    if [[ -z "$2" ]]; then
        _BRANCH="$(git rev-parse --abbrev-ref HEAD)"
        git_echo "::: Detected Branch: $_BRANCH"
    else
        _BRANCH="$2"
        git_echo "::: Requested Branch: $_BRANCH"
    fi
}

# aliases
# ----------------------------------------------------------------------------------
git-aliases() {
    git_echo "git-aliases is at $(git-ver)"
}

git-ver() {
    git_echo "v1.0-beta"
}

git-ll() {
    git log --abbrev-commit --decorate --pretty=format:"%C(yellow)%h %C(reset)-%C(red)%d %C(reset)%s %C(green)(%ar) %C(blue)[%an]" "$@"
}

git-it() {
    local _MESSAGE="$1"

    git add --all
    git commit -m "$_MESSAGE"
}

git-up() {
    git-it "$1"
    git-push "${@:2}"
}

git-amend() {
    git add --all
  
    if [ -n "$1" ]; then
        git commit --amend --reset-author --message="$1";
    else
        git commit --amend --reset-author --no-edit;
    fi;
    # in case to modify date: git commit --amend --date="$(date -R)"
}

git-push() {
    if [[ -z "$1" ]]; then local _ORIGIN; fi
    if [[ -z "$2" ]]; then local _BRANCH; fi
    git_detect_remote "${@:1:2}"

    git push "${_ORIGIN}" "${_BRANCH}" "${@:3}"
}

git-pushf() {
    if [[ -z "$1" ]]; then local _ORIGIN; fi
    if [[ -z "$2" ]]; then local _BRANCH; fi
    git_detect_remote "${@:1:2}"

    git push --force "${_ORIGIN}" "${_BRANCH}" "${@:3}"
}

git-pullf() {
    if [[ -z "$1" ]]; then local _ORIGIN; fi
    if [[ -z "$2" ]]; then local _BRANCH; fi
    git_detect_remote "${@:1:2}"

    git fetch --all
    git reset --hard "$_ORIGIN/$_BRANCH"
}

git-sync() {
    local _ORIGIN
    local _BRANCH
    git_detect_remote "${@:1:2}"

    git-clear
    git checkout "$_BRANCH"

    git-pullf "${_ORIGIN}" "${_BRANCH}"
    git remote prune "$_ORIGIN"

    git_echo
    git_echo "==> Synced with '$_ORIGIN/$_BRANCH'"
    git_echo
}

git-clean() {
    git gc --prune=now --aggressive

    git_echo
    git_echo "==> Git Repository Cleaned"
    git_echo
}

git-clear() {
    git reset --hard
    git clean -df

    git_echo
    git_echo "==> Git Repository Cleared"
    git_echo
}

git-fixit() {
    local _HASH="${1:-HEAD}"

    # Get a commit ref (long-hash-id)
    _HASH="$(git rev-parse "$_HASH")"

    git add --all
    git commit --no-verify --fixup "$_HASH"
}

git-fixup() {
    git-fixit "$1"
    git-push "${@:2}"
}

git-rebase() {
    EDITOR=true git rebase --interactive --autosquash --autostash --rebase-merges --no-fork-point "$@"
}

# miscellaneous
# ----------------------------------------------------------------------------------

pretty-code() {
    prettier --use-tabs false --tab-width 4 --print-width 1234567890 "$@"
}

} # this ensures the entire script is downloaded #
