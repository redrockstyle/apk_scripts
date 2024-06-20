#!/bin/bash

# Version
version="1.0.0"

IFS=$'\n'
GREEN='\033[0;32m'
NC='\033[0m'
prolog="apprun: "

die() { exit 1; }
print_version() {
    echo -e "Version:\t$version\n"
}
print_green() {
    echo -e "$GREEN$1$NC"
}
print_prolog() {
    echo "Small Runtime Assistent"
    echo "Requirements:   aapt, adb"
    echo "Repository:     github.com/redrockstyle/apk_scripts"
}
print_usage() {
    echo "Usage: apprun <command> <appname.apk>"
    echo "Commands:"
    echo -e "install\t\tClean install APK"
    echo -e "start\t\tStarting MainActivity"
    echo -e "force-stop\tForce-stop app"
    echo -e "remove\t\tAll uninstall APK"
}
print_example() {
    echo -e "Install:\tapprun i app.apk"
    echo -e "Remove:\t\tapprun remove app.apk"
    echo -e "Start:\t\tapprun s app.apk"
}
do_install() {
    echo "Install $1"
    adb install -r $1
}
do_start() {
    pkg=$(aapt dump badging $1|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
    act=$(aapt dump badging $1|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
    echo "Start $pkg/$act"
    adb shell am start -n $pkg/$act
}
do_force_stop() {
    pkg=$(aapt dump badging $1|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
    echo "Force-stop $pkg"
    adb shell am force-stop $pkg
}
do_remove() {
    pkg=$(aapt dump badging $1|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
    echo "Remove $pkg"
    # ignore flag -k and clear all data app
    adb shell pm uninstall $pkg
}

if [[ $# -eq 0 ]] ; then
    print_prolog
    print_version
    print_usage
    echo ""
    print_example
    die
fi


if [[ $# -ne 2 ]] ; then
    print_usage
    die
fi

case $1 in
    install) do_install $2 ;;
    start) do_start $2 ;;
    force-stop) do_force_stop $2 ;;
    remove) do_remove $2 ;;
    i) do_install $2 ;;
    s) do_start $2 ;;
    f) do_force_stop $2 ;;
    r) do_remove $2 ;;
    *) echo "Unsupported command"
        die ;;
esac
