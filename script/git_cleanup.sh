#!/bin/bash

# Local script call to make the repo smaller. History still there!
# Approx. duration: 30 minutes
#
# To see the size in Github: https://github.com/settings/repositories
#
# Call: . script/git_cleanup.sh

#set -x

echo "git cleanup takes min. 30 min..."
echo ""
echo "Directory size before:"
du -sh .
echo ""

git remote prune origin
git repack
git prune-packed
git reflog expire --all --expire=now
git gc --prune=now --aggressive

rm .git/refs/tags -Rf

echo ""
echo "Directory size after:"
du -sh .