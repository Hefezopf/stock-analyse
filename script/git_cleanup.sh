#!/bin/sh

# Local script call to make the repo smaller
#
# To see the size in Github: https://github.com/settings/repositories
#
# Call: sh ./script/git_cleanup.sh

#set -x

echo "git cleanup..."


echo "Directory size before:"
du -sh .

git remote prune origin
git repack
git prune-packed
git reflog expire --all --expire=now
git gc --prune=now --aggressive

rm .git/refs/tags -Rf

echo "Directory size after:"
du -sh .