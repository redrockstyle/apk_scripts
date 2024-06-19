#!/bin/bash

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
        echo -e "$1"
    fi
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
pkg=$(aapt dump badging $app|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
act=$(aapt dump badging $app|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
ver=$(aapt dump badging $app|awk -F" " '/package/ {print $4}'|awk -F"'" '/versionName=/ {print $2}')

echo "Package Name: $pkg"
echo "MainActivity: $act"
echo "Version: $ver"

perm=$(aapt d permissions $app | grep "permission:")
echo "Uses Permissions:"
IFS=$'\n'
for LINE in $perm
do
    if [[ $LINE == *"uses-permission:"* ]]; then
        echo " - `echo ${LINE} | cut -d \' -f 2`";
    fi
done
echo "Defines Permissions:"
for LINE in $perm
do
    if [[ $LINE != *"uses-permission:"* ]]; then
        echo " - `echo ${LINE} | cut -d ' ' -f 2`";
    fi
done

dp="device product:"
dev=$(adb devices -l 2>/dev/null | grep "$dp")
if [ $? -ne 0 ] ; then
    print_verbose "No device connections";
    die;
fi

pml=$(adb shell pm list package | grep "$pkg")
if [[ "${dev}" == *"${dp}"* ]] && [[ "${pml}" == *"${pkg}"* ]] ; then
    # If this pkg is installed
    echo -e "\nDevice Info"
    echo "IP: `echo $dev | cut -d ':' -f 1`"
    echo "Device: `echo $dev | awk -F "$dp" '{print $2}'`"
    echo "Version Android: `adb shell getprop ro.build.version.release`"
    echo "SDK Version: `adb shell getprop ro.build.version.sdk`"

    echo -e "\nPackage Info"
    echo "Path APK: `adb shell pm path $pkg | cut -d ':' -f 2`"
    echo "Path Data: /data/data/$pkg"
    echo "Link Data: /data/user/0/$pkg"

    adb root >/dev/null
    if [ $? -eq 0 ] ; then
        echo -e "\nOther Directories\n$(adb shell find /data -name "$pkg")"
    else
        print_verbose "ADB root restart failed"
    fi
fi


