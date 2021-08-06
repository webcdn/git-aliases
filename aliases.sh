#!/usr/bin/env bash

{ # this ensures the entire script is downloaded #

# Git Aliases
pretty-code() {
    prettier --use-tabs false --tab-width 4 --print-width 1234567890 "$@"
}

# helpers
# ----------------------------------------------------------------------------------
git_echo() {
    command printf %s\\n "$*" 2>/dev/null
}

git_detect_remote() {
    _ORIGIN="${1:-$(git remote)}"
    _BRANCH="${2:-$(git rev-parse --abbrev-ref HEAD)}"

    git_echo "::: Detected Remote: $_ORIGIN"
    git_echo "::: Detected Branch: $_BRANCH"
}

git-version() {
    git_echo "v0.0.1"
}

# aliases
# ----------------------------------------------------------------------------------
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
    
    if [ -n "$1" ];
    then git commit --amend -m "$1";
    else git commit --amend --no-edit;
    fi;
}

git-pullf() {
    git_detect_remote "${@:1:2}"

    git fetch --all
    git reset --hard "$_ORIGIN/$_BRANCH"
}

git-push() {
    git_detect_remote "${@:1:2}"

    git push "${_ORIGIN}" "${_BRANCH}" "$@"
}

git-pushf(){
    git_detect_remote "${@:1:2}"

    git push --force "${_ORIGIN}" "${_BRANCH}"
}

git-clean() {
    git gc --prune=now --aggressive

    git_echo
    git_echo "=> Git Repository Cleaned"
    git_echo
}

git-clear() {
    git reset --hard
    git clean -df

    git_echo
    git_echo "=> Git Repository Cleared"
    git_echo
}

git-sync() {
    git_detect_remote "${@:1:2}"

    git-clear
    git checkout "$_BRANCH"

    git pullf "${@:1:2}"
    git remote prune "$_ORIGIN"

    git_echo
    git_echo "=> Synced with '$_ORIGIN/$_BRANCH'"
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

} # this ensures the entire script is downloaded #
