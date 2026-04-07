#!/bin/bash

# Battery info
STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "0")
POWER_UW=$(cat /sys/class/power_supply/BAT0/power_now 2>/dev/null || echo "0")

# CPU energy performance preference
EPP=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || echo "N/A")

# Convert microwatts to watts
POWER_W=$(awk -v uw="$POWER_UW" 'BEGIN { printf "%.1f", uw / 1000000 }')

# Determine power mode
if [ "$STATUS" = "Discharging" ]; then
    MODE="BAT"
else
    MODE="AC"
fi

# Pick icon based on capacity and status
if [ "$STATUS" = "Charging" ]; then
    ICON="󰂄"
elif [ "$STATUS" = "Full" ] || [ "$STATUS" = "Not charging" ]; then
    ICON="󰚥"
elif [ "$CAPACITY" -ge 80 ]; then
    ICON="󰁹"
elif [ "$CAPACITY" -ge 60 ]; then
    ICON="󰂁"
elif [ "$CAPACITY" -ge 40 ]; then
    ICON="󰁿"
elif [ "$CAPACITY" -ge 20 ]; then
    ICON="󰁽"
else
    ICON="󰁺"
fi

# Determine CSS class for warning/critical states
CLASS=""
if [ "$STATUS" = "Discharging" ]; then
    if [ "$CAPACITY" -le 15 ]; then
        CLASS="critical"
    elif [ "$CAPACITY" -le 30 ]; then
        CLASS="warning"
    fi
fi

# Build tooltip
TOOLTIP="Power Mode: $MODE\nCPU Profile: $EPP\nPower Draw: ${POWER_W}W\nState: $STATUS"

# Output JSON for waybar
echo "{\"text\": \"$ICON $CAPACITY%\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
