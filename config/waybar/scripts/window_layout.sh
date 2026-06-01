#!/bin/bash

# Fetch active window details
active=$(hyprctl activewindow -j 2>/dev/null)

# If no active window
if [ -z "$active" ] || [ "$active" == "{}" ]; then
    echo '{"text": "󰖯", "tooltip": "No active window", "class": "none"}'
    exit 0
fi

# Check if the active window is floating
is_floating=$(echo "$active" | jq '.floating')

if [ "$is_floating" = "true" ]; then
    echo '{"text": "󰖲", "tooltip": "Mode: Floating\nClick to switch to Tiling", "class": "floating"}'
else
    echo '{"text": "󰖯", "tooltip": "Mode: Tiling\nClick to switch to Floating", "class": "tiling"}'
fi
