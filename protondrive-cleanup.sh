#!/bin/bash

# 1. Check that Terminal has full disk access
if ! plutil -lint /Library/Preferences/com.apple.TimeMachine.plist >/dev/null ; then
    echo "Please grant Full Disk Access permission to Terminal:"
    echo "1. Open System Preferences."
    echo "2. Go to Privacy & Security."
    echo "3. Scroll down and click Full Disk Access."
    echo "4. Click the + button."
    echo "5. Navigate to Applications -> Utilities, select Terminal, then click Open."
    echo "6. Make sure the checkbox next to Terminal is checked."
    echo "7. Close System Preferences."
    exit 1
fi

# 2. Kill all app-related processes that can use caches
appname="Proton Drive"
dirname="ProtonDrive"

if pgrep "$appname" >/dev/null; then
    pkill "$appname"
fi

# 3. Remove the defaults (this will remove both the file and the in-memory system cache)
defaults delete-all ch.protonmail.drive
defaults delete-all ~/Library/Group\ Containers/group.ch.protonmail.protondrive/Library/Preferences/group.ch.protonmail.protondrive.plist

# 4. Leftover paths
paths=(
    "/Applications/Proton Drive.app"
    "$HOME/Library/Preferences/*ch.protonmail.driv*"
    "$HOME/Library/Containers/*ch.protonmail.driv*"
    "$HOME/Library/Group Containers/*ch.protonmail.protondrive*"
    "$HOME/Library/Application Support/FileProvider/ch.protonmail.drive.fileprovider"
    "$HOME/Library/CloudStorage/$dirname-*"
)

# 5. Remove existing ones
for path in "${paths[@]}"; do
    while IFS= read -r -d $'\0' p; do
        if [[ -e "$p" ]]; then
            echo "🧹💨 $p"
            sudo rm -rf "${p}"
        fi
    done < <(find "${path%/*}" -name "${path##*/}" -maxdepth 1 -print0)
done

echo "Done!"
