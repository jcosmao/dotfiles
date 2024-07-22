#!/bin/bash

set -x
exec > /dev/null 2>&1

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

for p in $(ls $SCRIPTPATH/*.patch); do
    cd $HOME/.local/share/nvim/lazy/$(basename ${p%.patch})
    git reset --hard
    patch -p1 -tNr /dev/null < $p
    git config --local commit.gpgsign false
    git commit -am local
done
