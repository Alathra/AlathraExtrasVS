#!/bin/bash

PACKAGE_PREFIX=alathraextras

CLIENT_DIR="$(readlink -f "$APPDATA")/VintagestoryData/Mods" # directory with vintagestory mods
SERVER_DIR="$(readlink -f "$APPDATA")/Vintagestory/Mods" # directory with vintagestory mods
BUILD_DIR="./builds" # directory where we build the current repo to

function install_package() {
    local new_package="$1"
    # shellcheck disable=SC2124
    local install_dir="${@:2}"
    
    echo
    echo "Discovering mod packages matching '"$PACKAGE_PREFIX'* in'" $install_dir"
    echo
    ls -1 "$install_dir"/${PACKAGE_PREFIX}*
    echo

    echo "Removing mod packages matching '$PACKAGE_PREFIX*' from' $install_dir"
    echo
    rm "$install_dir"/${PACKAGE_PREFIX}*

    echo "Installing built package'$new_package' to $install_dir"
    cp "$new_package" "$install_dir"
}

function build_package() {
    local timestamp
    timestamp=$(date +%s)
    local package_path="${BUILD_DIR}/${PACKAGE_PREFIX}_${timestamp}.zip"
    (
        echo
        echo "Building new package to: '$package_path'..."
        echo
        zip "$package_path" -r assets LICENSE modinfo.json README.md
    ) >&2

    echo "$package_path"
}

# shellcheck disable=SC2046
cd $(dirname "$0")/.. || (echo could not change directory && exit 1)

NEW_PACKAGE="$(build_package)"
echo hi
echo "$NEW_PACKAGE"
build_package

install_package "$NEW_PACKAGE" "$CLIENT_DIR"
install_package "$NEW_PACKAGE" "$SERVER_DIR"