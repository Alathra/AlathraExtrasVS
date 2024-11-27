#!/bin/bash -eu
#set -x

SOURCE_DIR="../../vs-server-config/servers/dev/Mods" # directory with mods from git repo
CLIENT_DIR="$APPDATA/VintagestoryData/Mods" # directory with vintagestory mods
SERVER_DIR="$APPDATA/Vintagestory/Mods" # directory with vintagestory mods

# List mods that should not be touched
EXCLUDED_FILES=(
bodyheatbar.zip      
ClaimRadars-1.1.0.zip
ExtraInfo-v1.8.1.zip
hudclock-3.4.0.zip
VSCreativeMod.dll
VSCreativeMod.pdb
VSEssentials.dll
VSEssentials.pdb
VSSurvivalMod.dll
VSSurvivalMod.pdb
)

function join_array() {
    local array=("$@")
    local delimiter='|'
 
    joined_array=$(printf "${delimiter}%s" "${array[@]}")
    joined_array=${joined_array:1}

    echo "${joined_array}"
}

function cp_files() {
    local dest_dir="${1}"

    echo "Copying files from  '$SOURCE_DIR' to '$dest_dir, using exclusion Regex: $EXCLUDED_REGEX'"

    local exclude_file
    SAVEIFS=$IFS; IFS=$(echo -en "\n\b")
    for file in $(ls -1 "$SOURCE_DIR"); do
        echo $file | grep -q -E "$EXCLUDED_REGEX" 
        exclude_file=$?

        if [[ $exclude_file -eq 0 ]]; then
        echo "excluding $file"
            continue
        fi

        echo copying $file
        cp "$SOURCE_DIR/$file" "$dest_dir"
    done
    IFS=$SAVEIFS
}

function rm_files() {
    local dest_dir="${1}"

    echo "Removing files from '$dest_dir, using exclusion Regex: $EXCLUDED_REGEX'"
    local exclude_file

    SAVEIFS=$IFS; IFS=$(echo -en "\n\b")
    for file in $(ls -1 "$dest_dir"); do
        echo $file | grep -q -E "$EXCLUDED_REGEX" 
        exclude_file=$?

        if [[ $exclude_file -eq 0 ]]; then
        echo "excluding $file"
            continue
        fi

        echo removing $file
        rm "$dest_dir/$file"
    done
    IFS=$SAVEIFS
}

function sync_files() {
    local dest_dir="${1}"
    # Remove all files except excluded ones
    rm_files "$dest_dir"
    # Copy all files except excluded ones
    cp_files "$dest_dir"
}

function prompt() {
    echo "This script is potentially destructive! Make sure your variables are correct before proceeding"
    echo
    echo "Source Dir: $SOURCE_DIR"
    echo "Client Dir: $CLIENT_DIR"
    echo "Server Dir: $SERVER_DIR"
    echo "Exclusion Regex: $EXCLUDED_REGEX"
    echo
    read -r -p "Are you sure you want to continue? [y/N]" -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Confirmation received. Continuing..."
    else
        echo "Confirmation not received. Exiting!"
        exit 1
    fi
}

function main() {
    EXCLUDED_REGEX=$(join_array "${EXCLUDED_FILES[@]}")
    prompt 
    sync_files "$CLIENT_DIR"
    sync_files "$SERVER_DIR"
}

main "$@"
