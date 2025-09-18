#!/bin/bash

uninstall_src(){
    name_bin=$1
    usr_dir=$2

    usr_path="/usr/local/bin/$name_bin"

    if [ ! -f "$usr_path" ]; then
      printf "%-10s %-26s %s\n" "$name_bin" "$usr_path" "Failed: Tool is not found"
    else
      rm -f "$usr_path"
      printf "%-10s %-26s %s\n" "$name_bin" "$usr_path" "Success"
    fi
}

echo "Unistalling apk_scripts..."

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

printf "%-10s %-26s %s\n" "Tool" "Path" "Status"
uninstall_src "appquick" "/usr/local/bin"
uninstall_src "appinfo"  "/usr/local/bin"
uninstall_src "apprun"   "/usr/local/bin"
uninstall_src "getcert"  "/usr/local/bin"
rm -rf "$opt_dir"

echo "Done"
exit 0
