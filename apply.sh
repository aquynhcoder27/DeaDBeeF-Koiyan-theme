#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
THEME_FILE="$SCRIPT_DIR/deadbeef-theme.conf"

if [ "$#" -gt 1 ]; then
    echo "Usage: sh ./apply.sh [path/to/deadbeef/config]" >&2
    exit 2
fi

if [ "$#" -eq 1 ]; then
    CONFIG_FILE=$1
else
    CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME:?HOME must be set}/.config}
    CONFIG_FILE="$CONFIG_HOME/deadbeef/config"
fi

if [ ! -s "$THEME_FILE" ]; then
    echo "Theme file is missing or empty: $THEME_FILE" >&2
    exit 1
fi

if [ -L "$CONFIG_FILE" ]; then
    echo "Refusing to replace a symlink: $CONFIG_FILE" >&2
    exit 1
fi

CONFIG_DIR=$(dirname "$CONFIG_FILE")
mkdir -p "$CONFIG_DIR"
umask 077
TEMP_FILE="$CONFIG_FILE.tmp.$$"
BACKUP_FILE=

cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup 0
trap 'exit 1' HUP INT TERM

if [ -f "$CONFIG_FILE" ]; then
    awk '
        FNR == NR {
            if (NF && $1 !~ /^#/) {
                key = $1
                if (!(key in theme)) order[++count] = key
                theme[key] = $0
            }
            next
        }
        {
            key = $1
            if (key in theme) {
                if (!emitted[key]++) print theme[key]
            }
            else print
        }
        END {
            for (i = 1; i <= count; i++) {
                key = order[i]
                if (!(key in emitted)) print theme[key]
            }
        }
    ' "$THEME_FILE" "$CONFIG_FILE" > "$TEMP_FILE"
else
    cp "$THEME_FILE" "$TEMP_FILE"
fi

chmod 600 "$TEMP_FILE"

if [ -f "$CONFIG_FILE" ]; then
    TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
    BACKUP_FILE="$CONFIG_FILE.backup-$TIMESTAMP-$$"
    cp -p "$CONFIG_FILE" "$BACKUP_FILE"
    chmod 600 "$BACKUP_FILE"
fi

mv "$TEMP_FILE" "$CONFIG_FILE"

if [ -n "$BACKUP_FILE" ]; then
    echo "Updated: $CONFIG_FILE"
    echo "Backup:  $BACKUP_FILE"
else
    echo "Created: $CONFIG_FILE"
fi
