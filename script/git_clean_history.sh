#!/bin/bash

# Local script call to make the history of the repo smaller
# Clear history of these 3 directores: buy, sell and alarm
# Because their filenames differ each day. E.g.: buy\0OK_2023-01-20.txt
# Recommented run frequency: once a year
# Approx. duration: 4 hours!
#
# Status: January 2023 (after cleanup):
# See repo size in Github: https://github.com/settings/repositories
# ->328 MB
# See local repo size
# du -sh .
# -> 558 M
#
# Call: . script/git_clean_history.sh

#set -x

echo "git clean history..."
echo ""
echo "Directory size before:"
du -sh .
echo ""
echo "Objects count before:"
git count-objects -vH

echo "Make backup of 3 directories..."
cp buy temp/buy -r
cp sell temp/sell -r
cp alarm temp/alarm -r

git filter-branch --index-filter 'git rm -rf --cached --ignore-unmatch buy' --prune-empty -- --all
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d
rm -Rf .git/logs .git/refs/original

git filter-branch --index-filter 'git rm -rf --cached --ignore-unmatch sell' --prune-empty -- --all
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d
rm -Rf .git/logs .git/refs/original

git filter-branch --index-filter 'git rm -rf --cached --ignore-unmatch alarm' --prune-empty -- --all
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d
rm -Rf .git/logs .git/refs/original

echo "Restore backup of 3 directories..."
cp temp/buy . -r
cp temp/sell . -r
cp temp/alarm . -r

rm temp/buy -rf
rm temp/sell -rf
rm temp/alarm -rf

git gc --prune=all --aggressive
git push origin --all --force
git push origin --tags --force

echo ""
echo "Directory size after:"
du -sh .
echo "Objects count after:"
git count-objects -vH