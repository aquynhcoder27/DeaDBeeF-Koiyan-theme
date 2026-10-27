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

if [ -e "$CONFIG_FILE" ] && [ ! -f "$CONFIG_FILE" ]; then
    echo "Refusing to replace a non-regular file: $CONFIG_FILE" >&2
    exit 1
fi

CONFIG_DIR=$(dirname "$CONFIG_FILE")
mkdir -p "$CONFIG_DIR"
umask 077
TEMP_FILE=
BACKUP_FILE=
BACKUP_READY=0

cleanup() {
    if [ -n "$TEMP_FILE" ]; then
        rm -f "$TEMP_FILE" || :
    fi
    if [ -n "$BACKUP_FILE" ] && [ "$BACKUP_READY" -eq 0 ]; then
        rm -f "$BACKUP_FILE" || :
    fi
}
trap cleanup 0
trap 'exit 1' HUP INT TERM

TEMP_FILE=$(mktemp "$CONFIG_DIR/.deadbeef-theme.tmp.XXXXXX")

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
    BACKUP_FILE=$(mktemp "$CONFIG_FILE.backup-$TIMESTAMP-XXXXXX")
    if ! cat "$CONFIG_FILE" > "$BACKUP_FILE"; then
        echo "Failed to create backup: $BACKUP_FILE" >&2
        exit 1
    fi
    chmod 600 "$BACKUP_FILE"
    BACKUP_READY=1
fi

mv -T "$TEMP_FILE" "$CONFIG_FILE"

if [ -n "$BACKUP_FILE" ]; then
    echo "Updated: $CONFIG_FILE"
    echo "Backup:  $BACKUP_FILE"
else
    echo "Created: $CONFIG_FILE"
fi
