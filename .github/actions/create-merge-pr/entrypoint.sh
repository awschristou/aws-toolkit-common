#!/bin/sh -l

set -e

# git config --global user.name "${GITHUB_ACTOR}"
# git config --global user.email "${GITHUB_ACTOR}"
git config --global --add safe.directory /github/workspace

echo "Hello world"

srcbranch=$1
dstbranch=$2
mrgbranch=$3

echo source $srcbranch
echo destination $dstbranch
echo mergeto $mrgbranch

echo Branches:
git branch -r --list

if [ -z "$(git branch -r --list origin/$mrgbranch)" ]; then
    # this branch doesn't exist
    
    echo Fetching $dstbranch
    git fetch origin "$dstbranch":"$dstbranch"

    echo Switching to $dstbranch
    git checkout "$dstbranch"

    echo Creating $mrgbranch
    git checkout -b "$mrgbranch"

    echo Merging in $srcbranch
    git merge "$srcbranch"

    echo Pushing...
    git push --set-upstream origin "$mrgbranch"
else
    # Branch is already in progress. Merge src into it

    echo Fetching $mrgbranch
    git fetch origin "$mrgbranch":"$mrgbranch"

    echo Switching to $mrgbranch
    git checkout "$mrgbranch"

    echo Merging in $srcbranch
    git merge "$srcbranch"

    echo Pushing...
    git push --set-upstream origin "$mrgbranch"
fi

# Make PR if it doesn't exist

if gh pr list --base "$dstbranch" --head "$mrgbranch" --state open --json number | grep -q 'number'; then
    echo "There is already a PR for this automerge"
else
    echo "Creating PR"
    prTitle="Merge $srcbranch into $dstbranch"

    echo "Automatic merge failed due to conflicts - Manual resolution is required" >> pr-body.txt

    gh pr create --base "$dstbranch" --head "$mrgbranch" --body-file pr-body.txt --title "$prTitle"
fi
