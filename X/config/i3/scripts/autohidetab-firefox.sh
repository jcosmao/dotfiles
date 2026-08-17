#!/bin/bash

pkill firefox

find ~/.mozilla -name prefs.js | while read -r pref; do
    profile=$(dirname "$pref")
    cat "$pref" | grep -q '^user_pref("toolkit.legacyUserProfileCustomizations.stylesheets'

    if [[ $? -eq 0 ]]; then
        sed 's/user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", false);/user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);/' -i $pref
    else
        echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> $pref
    fi

    mkdir -p $profile/chrome
    cat <<EOF > "$profile/chrome/userChrome.css"
#main-window[titlepreface*="[Sidebery]"] #TabsToolbar {visibility: collapse !important;}
#main-window[titlepreface*="[Sidebery]"] #titlebar {visibility: collapse !important;}
EOF
done
