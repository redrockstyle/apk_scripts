#!/bin/bash

version="1.2.1"

IFS=$'\n'
RED='\033[0;31m'
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
print_red() {
    echo -e "$RED$1$NC"
}
msg_and_die() {
    print_red $1
    die
}
print_prolog() {
    echo "Small Runtime Assistent"
    echo "Requirements:   aapt, adb, qpdf, openssl, apksigner"
    echo "Repository:     github.com/redrockstyle/apk_scripts"
}
print_usage() {
    echo "Usage: apprun <command> <command_argument>"
    echo -e "(i)  install\t- Clean install APK"
    echo -e "(s)  start\t- Starting MainActivity"
    echo -e "(f)  force-stop\t- Force-stop app"
    echo -e "(rm) remove\t- Full uninstall app"
    echo -e "(b)  backup\t- Backup data app"
    echo -e "(r)  restore\t- Restore data app"
    echo -e "(e)  extract\t- Extract backup file"
    echo -e "(bc) burpcert\t- Push burp cert in the system storage"
    echo -e "(sp) setproxy\t- Set http proxy android"
    echo -e "(pc) printcert\t- Print certs APK package"
    echo -e "(lc) logcat\t- Print logcat for app"
}
print_example() {
    echo -e "Install:\tapprun i app.apk"
    echo -e "Remove:\t\tapprun remove app.apk"
    echo -e "Set proxy:\tapprun sp 192.168.1.100:8080"
    echo -e "Disable proxy:\tapprun sp :0"
    echo -e "Backup app:\tapprun backup app.apk"
    echo -e "Logcat app:\tapprun lc some.package.name"
    echo -e "Logcat app:\tapprun lc app.apk"
}
get_pkg_name() {
    pkg=''
    ret=$2
    if [[ $(adb shell pm list package | grep "$1") == *"$1"* ]] ; then
        pkg="$1"
        ret="$pkg";
    else
        pkg=$(aapt dump badging $1 2>/dev/null|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
        if [ $? -eq 0 ] ; then
            ret="$pkg";
        else
            ret="";
        fi
    fi
}
check_appname() {
    if [[ $1 == "" ]] ; then
        msg_and_die "App is not installed"
    fi
}
check_connect() {
    dev=$(adb devices -l 2>/dev/null | grep "device product")
    if [ $? -ne 0 ] ; then
        msg_and_die "Device is not connected"
    fi
    count=$(echo $dev | wc -l)
    if [ $count -ne 1 ] ; then
        msg_and_die "Connected $count devices (one connect supported)"
    fi
}
do_install() {
    check_connect
    echo "Install $1"
    adb install -r $1
}
do_start() {
    check_connect
    pkg=$(aapt dump badging $1|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
    act=$(aapt dump badging $1|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
    echo "Start $pkg/$act"
    adb shell am start -n $pkg/$act
}
do_force_stop() {
    check_connect
    pkg=''
    get_pkg_name $1 pkg
    check_appname $pkg

    echo "Force-stop $pkg"
    adb shell am force-stop $pkg
}
do_remove() {
    check_connect
    pkg=''
    get_pkg_name $1 pkg
    check_appname $pkg

    echo "Remove $pkg"
    # ignore flag -k and clear all data app
    adb shell pm uninstall $pkg
}
do_backup() {
    check_connect
    pkg=''
    get_pkg_name $1 pkg
    check_appname $pkg

    echo "Backup $pkg"
    adb backup -apk $pkg -f $pkg.backup
    echo "Saved in $pkg.backup"
}
do_restore() {
    check_connect
    echo -e "Restore data from $1"
    adb restore $1
}
do_extract() {
    echo "Extract backup $1 file"
    dd if=$1 bs=24 skip=1 | zlib-flate -uncompress | tar xf -
}
do_burpcert() {
    check_connect
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
    check_connect
    echo "Set $1 http proxy"
    adb shell settings put global http_proxy $1
}
do_printcerts(){
    apksigner verify --print-certs -v $1
}
do_logcatapp(){
    check_connect
    echo "Start logcat"
    adb logcat -T 1000 io.faceapp:V *:S -v color
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
    restore) do_restore $2 ;;
    extract) do_extract $2 ;;
    burpcert) do_burpcert $2 ;;
    setproxy) do_setproxy $2 ;;
    printcert) do_printcerts $2 ;;
    logcat) do_logcatapp $2 ;;
    i) do_install $2 ;;
    s) do_start $2 ;;
    f) do_force_stop $2 ;;
    rm) do_remove $2 ;;
    b) do_backup $2 ;;
    r) do_restore $2 ;;
    e) do_extract $2 ;;
    bc) do_burpcert $2 ;;
    sp) do_setproxy $2 ;;
    pc) do_printcerts $2 ;;
    lc) do_logcatapp $2 ;;
    *) print_red "Unsupported command"
        die ;;
esac
