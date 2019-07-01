#!/usr/bin/env bash

tmpbg="/tmp/$(basename $0).png"

rm -f "$tmpbg"
scrot "$tmpbg"
convert "$tmpbg" -scale 10% -scale 1000% "$tmpbg"
i3lock -i "$tmpbg"
chmod 777 $tmpbg

exit 0
