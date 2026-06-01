#!/bin/bash

STATE_FILE="/home/kylle/archdatback/config/hypr/global_mode.conf"
WAYBAR_STATE="/tmp/waybar_global_mode"

# Initialize if not exists
if [ ! -f "$WAYBAR_STATE" ]; then
    echo "tiling" > "$WAYBAR_STATE"
    touch "$STATE_FILE"
fi

CURRENT_MODE=$(cat "$WAYBAR_STATE")

if [ "$1" == "toggle" ]; then
    if [ "$CURRENT_MODE" == "tiling" ]; then
        echo "floating" > "$WAYBAR_STATE"
        cat << 'EOF' > "$STATE_FILE"
windowrule {
    name = global-float
    match:class = .*
    float = yes
    center = on
    size = 50% 50%
}
EOF
        
        # Float all existing windows
        hyprctl clients -j | python3 -c 'import json, sys; [print(x["address"]) for x in json.load(sys.stdin) if not x["floating"]]' | while read -r addr; do
            hyprctl dispatch togglefloating "address:$addr"
        done
    else
        echo "tiling" > "$WAYBAR_STATE"
        echo "" > "$STATE_FILE"
        
        # Tile all existing windows
        hyprctl clients -j | python3 -c 'import json, sys; [print(x["address"]) for x in json.load(sys.stdin) if x["floating"]]' | while read -r addr; do
            hyprctl dispatch togglefloating "address:$addr"
        done
    fi
    hyprctl reload
    exit 0
fi

# Status output for waybar
CURRENT_MODE=$(cat "$WAYBAR_STATE")
if [ "$CURRENT_MODE" == "floating" ]; then
    echo '{"text": "󰖲 Float", "tooltip": "Global Mode: Floating\nClick to switch all to Tiling", "class": "floating"}'
else
    echo '{"text": "󰖯 Tile", "tooltip": "Global Mode: Tiling\nClick to switch all to Floating", "class": "tiling"}'
fi
