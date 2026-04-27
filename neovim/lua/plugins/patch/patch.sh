#!/bin/bash

mkdir -p /tmp/nvim/
exec &> >(tee -a /tmp/nvim/plugins_patch.log)

set -ex

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

patch_file=$1
patch_path=${SCRIPTPATH}/${patch_file}
module_name=$(basename ${patch_file%.patch})
module_path=$HOME/.local/share/nvim/lazy/${module_name}

if [[ ! -e $module_path || ! -e $patch_path ]]; then
    exit 1
fi

git -C $module_path apply --abort || true
git -C $module_path reset --hard
git -C $module_path clean -fdx
git -C $module_path config --local commit.gpgsign false
git -C $module_path apply -3 ${patch_path} && git -C $module_path commit -am "$1"
