#!/bin/sh -l

set -e

git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${GITHUB_ACTOR}"
git config --global --add safe.directory /github/workspace

echo "Hello world"

srcbranch=$1
dstbranch=$2
mrgbranch=$3

title="Merge $srcbranch into $dstbranch"

echo source $srcbranch
echo destination $dstbranch
echo mergeto $mrgbranch

if [ -z "$(git branch --list $mrgbranch)" ]; then
    # this branch doesn't exist
    git checkout $dstbranch
    git checkout -b $mrgbranch
    git merge $srcbranch
    git push --set-upstream origin $mrgbranch
else
    # Branch is already in progress. Merge src into it
    git checkout $mrgbranch
    git merge $dstbranch
    git push --set-upstream origin $mrgbranch
fi

# Make PR if it doesn't exist
