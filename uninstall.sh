#!/bin/bash

uninstall_src(){
    name_bin=$1
    usr_dir=$2

    usr_path="/usr/local/bin/$name_bin"

    if [ ! -f "$usr_path" ]; then
        echo "Error: Source script '$usr_path' not found in the current directory."
        exit 1
    fi
    rm -f "$usr_path"
    echo "$name_bin ($usr_path) successful uninstalled"
}

echo "Unistalling apk_scripts..."

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

uninstall_src "appquick" "/usr/local/bin"
uninstall_src "apprun" "/usr/local/bin"
rm -rf "$opt_dir"

echo "Done"
exit 0
