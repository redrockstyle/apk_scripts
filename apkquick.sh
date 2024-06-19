#!/bin/bash

BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

app=''
v_flag=0
die() { exit 1; }
print_logo() {
    echo -e "A little info about the APK package"
    echo -e "Just give your APK file :D\n"
    print_usage
    echo -e "-a\tSelect APK file"
    echo -e "-v\tVerbose mode"
}
print_usage() { echo "Usage: appquick [-v] -a <appname.apk>";}
print_verbose() {
    if [ $v_flag -eq 1 ] ; then
        print_blue $1;
    fi
}
print_green() {
    echo -e "$GREEN$1$NC"
}
print_red() {
    echo -e "$RED$1$NC"
}
print_blue() {
    echo -e "$BLUE$1$NC"
}


if [[ $# -eq 0 ]] ; then
    print_logo;
    die;
fi

while getopts 'a:v' flag; do
  case "${flag}" in
    a) app="${OPTARG}" ;;
    v) v_flag=1 ;;
    *) print_usage
       die ;;
  esac
done

if [ -z $app ] ; then
    print_verbose "No such argument -a"
    print_usage;
    die;
fi

# Static info
print_verbose "Parse aapt dump badging and get pkg info"
pkg=$(aapt dump badging $app|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
act=$(aapt dump badging $app|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
ver=$(aapt dump badging $app|awk -F" " '/package/ {print $4}'|awk -F"'" '/versionName=/ {print $2}')

print_green "Simple info"
echo "Package Name: $pkg"
echo "MainActivity: $act"
echo "Version: $ver"

print_verbose "\nParse aapt permissions"
perm=$(aapt d permissions $app | grep "permission:")
print_green "Uses Permissions:"
IFS=$'\n'
for LINE in $perm
do
    if [[ $LINE == *"uses-permission:"* ]]; then
        echo " - `echo ${LINE} | cut -d \' -f 2`";
    fi
done
print_green "Defines Permissions:"
for LINE in $perm
do
    if [[ $LINE != *"uses-permission:"* ]]; then
        echo " - `echo ${LINE} | cut -d ' ' -f 2`";
    fi
done

echo ""
print_verbose "Find device connection"
dp="device product:"
dev=$(adb devices -l 2>/dev/null | grep "$dp")
if [ $? -ne 0 ] ; then
    print_verbose "No device connections";
    die;
fi
print_verbose "Device is found"

pml=$(adb shell pm list package | grep "$pkg")
if [[ "${dev}" == *"${dp}"* ]] && [[ "${pml}" == *"${pkg}"* ]] ; then
    # If this pkg is installed
    echo ""
    print_verbose "Get info of device with adb shell getprop"
    print_green "Device Info"
    echo "IP: `echo $dev | cut -d ':' -f 1`"
    echo "Device: `echo $dev | awk -F "$dp" '{print $2}'`"
    echo "Version Android: `adb shell getprop ro.build.version.release`"
    echo "SDK Version: `adb shell getprop ro.build.version.sdk`"

    echo ""
    print_verbose "Get location info installed app"
    print_green "Package Info"
    echo "Path APK: `adb shell pm path $pkg | cut -d ':' -f 2`"
    echo "Path Data: /data/data/$pkg"
    echo "Link Data: /data/user/0/$pkg"

    echo ""
    print_verbose "Get location info with find /data command"
    adb root >/dev/null
    if [ $? -eq 0 ] ; then
        print_green "Other Directories"
        echo "$(adb shell find /data -name "$pkg")"
    else
        print_verbose "ADB root restart failed"
    fi
fi

