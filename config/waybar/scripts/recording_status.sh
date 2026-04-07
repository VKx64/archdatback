#!/bin/bash

count=$(pgrep -xc wf-recorder 2>/dev/null || true)

if [ "$count" -le 0 ]; then
    exit 0
fi

if [ "$count" -eq 1 ]; then
    tooltip="Screen recording in progress\\nClick to stop"
else
    tooltip="$count wf-recorder processes running\\nClick to stop all"
fi

printf '{"text":"󰑋 REC","tooltip":"%s","class":"recording"}\n' "$tooltip"
