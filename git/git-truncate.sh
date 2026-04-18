#!/bin/bash

#   Usage:
#   ./git-truncate.sh SHA1
#       Removes all the history prior to commit "SHA1"

if [[ -z $1 ]]; then
    echo "$0 <commit sha1>"
    exit 1
fi

git checkout --orphan temp $1
git commit -m "Truncated history of git repo"
git rebase --onto temp $1 master
git branch -D temp

# Optional, may take awhile
git prune --progress
git gc --aggressive
