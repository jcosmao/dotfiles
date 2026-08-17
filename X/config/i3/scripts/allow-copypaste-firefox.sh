#!/bin/bash

pkill firefox

find ~/.mozilla -name prefs.js | while read -r pref; do
    if grep -q '^user_pref("dom.event.clipboardevents.enabled' < "$pref"; then
        sed 's/user_pref("dom.event.clipboardevents.enabled", true);/user_pref("dom.event.clipboardevents.enabled", false);/' -i "$pref"
    else
        echo 'user_pref("dom.event.clipboardevents.enabled", false);' >> "$pref"
    fi
done
