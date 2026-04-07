#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/archdatback/wallpaper"
HYPRPAPER_CONF="$HOME/archdatback/config/hypr/hyprpaper.conf"
ROFI_CONF="$HOME/archdatback/config/rofi/wallpaper.conf"
SCRIPT="$HOME/archdatback/scripts/wallpaper-switcher.sh"

# Phase 1: Initial call — build the menu
if [[ "$ROFI_RETV" == "0" ]]; then
    for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp,gif}; do
        [[ -f "$img" ]] || continue
        filename="$(basename "$img")"
        printf '%s\0icon\x1f%s\n' "$filename" "$img"
    done
    exit 0
fi

# Phase 2: User selected an entry
if [[ "$ROFI_RETV" == "1" ]]; then
    SELECTED="$WALLPAPER_DIR/$1"

    [[ -f "$SELECTED" ]] || exit 1

    # Apply wallpaper via IPC first for instant switch
    hyprctl hyprpaper wallpaper "eDP-1, $SELECTED"
    hyprctl hyprpaper wallpaper ", $SELECTED"

    # Persist to hyprpaper.conf after so it survives restarts
    awk -v newpath="$SELECTED" '
        /wallpaper \{/ { in_block=1 }
        in_block && /path =/ { sub(/path = .*/, "path = " newpath) }
        /^\}/ { in_block=0 }
        { print }
    ' "$HYPRPAPER_CONF" > "${HYPRPAPER_CONF}.tmp" && mv "${HYPRPAPER_CONF}.tmp" "$HYPRPAPER_CONF"

    exit 0
fi

# Entry point: launch rofi in script mode using this script and our dedicated config
exec rofi -show wallpaper \
    -modes "wallpaper:$SCRIPT" \
    -config "$ROFI_CONF" \
    -no-fixed-num-lines
