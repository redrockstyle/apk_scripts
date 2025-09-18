#!/bin/bash

install_src(){
    filename=$1
    name_dir=$2
    name_bin=$3

    if [ ! -f "$filename" ]; then
      printf "%-10s %-26s %s\n" "$name_bin" "<Not copied>" "Failed: Source script is not found"
    else
      opt_path="$name_dir/$filename"
      usr_path="/usr/local/bin/$name_bin"

      mkdir -p $name_dir
      cp "$filename" "$opt_path"
      chmod +x "$opt_path"
      ln -sf "$opt_path" "$usr_path"

      printf "%-10s %-26s %s\n" "$name_bin" "$usr_path" "Success"
    fi
}

echo "Installing apk_scripts..."

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

printf "%-10s %-26s %s\n" "Tool" "Path" "Status"
install_src "appquick.sh" "/opt/src/apk_scripts" "appquick"
install_src "appinfo.sh"  "/opt/src/apk_scripts" "appinfo"
install_src "apprun.sh"   "/opt/src/apk_scripts" "apprun"
install_src "getcert.sh"  "/opt/src/apk_scripts" "getcert"

echo "Done"
exit 0
