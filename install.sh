#!/bin/bash

install_src(){
    filename=$1
    name_dir=$2
    name_bin=$3

    if [ ! -f "$filename" ]; then
        echo "Error: Source script '$filename' not found in the current directory."
        exit 1
    fi
    opt_path="$name_dir/$filename"
    usr_path="/usr/local/bin/$name_bin"

    mkdir -p $name_dir
    cp "$filename" "$opt_path"
    chmod +x "$opt_path"
    ln -sf "$opt_path" "$usr_path"

    echo "$name_bin ($usr_path) successful installed"
}

echo "Installing apk_scripts..."

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

install_src "appquick.sh" "/opt/src/apk_scripts" "appquick"
install_src "apprun.sh" "/opt/src/apk_scripts" "apprun"

echo "Done"
exit 0
