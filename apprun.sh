#!/bin/bash

version="1.1.0"

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
    echo "Requirements:   aapt, adb, qpdf"
    echo "Repository:     github.com/redrockstyle/apk_scripts"
}
print_usage() {
    echo "Usage: apprun <command> <command_argument>"
    echo "Commands:"
    echo -e "install (i)\tClean install APK"
    echo -e "start (s)\tStarting MainActivity"
    echo -e "force-stop (f)\tForce-stop app"
    echo -e "remove (r)\tFull uninstall app"
    echo -e "backup (b)\tBackup app"
    echo -e "extract (e)\tExtract backup file"
    echo -e "burpcert (bc)\tPush burp cert in the system storage"
    echo -e "setproxy (sp)\tSet http proxy android"
}
print_example() {
    echo -e "Install:\tapprun i app.apk"
    echo -e "Remove:\t\tapprun remove app.apk"
    echo -e "Set proxy:\tapprun sp 192.168.1.100:8080"
    echo -e "Disable proxy:\tapprun sp :0"
    echo -e "Backup app:\tapprun backup app.apk"
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
do_backup() {
    echo $1
    if [[ $(adb shell pm list package | grep "$1") == *"$1"* ]] ; then
        echo "Backup $1"
        adb backup -apk $1 -f $1.adb
    else
        pkg=$(aapt dump badging $1|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
        echo "Backup $pkg"
        adb backup -apk $pkg -f $pkg.adb
    fi
}
do_extract() {
    echo "Extract backup $1 file"
    dd if=$1 bs=24 skip=1 | zlib-flate -uncompress | tar xf -
}
do_burpcert() {
    tmp_pem="bcert.pem"
    echo "Convert certificate"
    openssl x509 -inform DER -in $1 -out "${tmp_pem}"
    tmp_name=$(openssl x509 -inform PEM -subject_hash_old -in "${tmp_pem}" |head -1)
    mv "${tmp_pem}" "${tmp_name}".0
    echo "Reload ADB root"
    adb root
    echo "Push certificate ${tmp_name}.0 to /system/etc/security/cacerts/${tmp_name}"
    adb push "${tmp_name}".0 /system/etc/security/cacerts/.
    rm "${tmp_name}".0
}
do_setproxy() {
    echo "Set $1 http proxy"
    adb shell settings put global http_proxy $1
}

if [[ $# -eq 0 ]] ; then
    print_prolog
    print_version
    print_usage
    echo -e "\nExamples"
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
    backup) do_backup $2 ;;
    extract) do_extract $2 ;;
    burpcert) do_burpcert $2 ;;
    setproxy) do_setproxy $2 ;; 
    i) do_install $2 ;;
    s) do_start $2 ;;
    f) do_force_stop $2 ;;
    r) do_remove $2 ;;
    b) do_backup $2 ;;
    e) do_extract $2 ;;
    bc) do_burpcert $2 ;;
    sp) do_setproxy $2 ;;
    *) echo "Unsupported command"
        die ;;
esac
