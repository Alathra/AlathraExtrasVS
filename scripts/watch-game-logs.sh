#!/bin/bash -eu
#set -x
LOGS_DIR="$APPDATA/VintagestoryData/Logs" # directory with vintagestory Logs

cd "$LOGS_DIR"
tail -f *