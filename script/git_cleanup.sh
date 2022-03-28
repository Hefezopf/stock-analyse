#!/bin/sh

# Local script call to make the repo smaller

# Call: sh ./script/git_cleanup.sh

#set -x

echo "git cleanup..."

git reflog expire --all --expire=now
git gc --prune=now --aggressive
git remote prune origin
rm .git/refs/tags -Rf