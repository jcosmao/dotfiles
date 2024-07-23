#!/bin/bash

mkdir -p /tmp/nvim/
exec &> >(tee -a /tmp/nvim/plugins_patch.log)

set -x

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

for p in $(ls $SCRIPTPATH/*.patch); do
    cd $HOME/.local/share/nvim/lazy/$(basename ${p%.patch})
    git reset --hard
    git config --local commit.gpgsign false
    git am -3 < $p
done
