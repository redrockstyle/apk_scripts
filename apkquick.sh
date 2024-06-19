#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo "Usage: appquick <appname.apk>"
    exit 1
fi

# Static info
pkg=$(aapt dump badging $1|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
act=$(aapt dump badging $1|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
ver=$(aapt dump badging $1|awk -F" " '/package/ {print $4}'|awk -F"'" '/versionName=/ {print $2}')

echo "Package Name: $pkg"
echo "MainActivity: $act"
echo "Version: $ver"

perm=$(aapt d permissions $1 | grep "permission:")
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
dev=$(adb devices -l | grep "$dp")
pml=$(adb shell pm list package | grep "$pkg")
if [[ "${dev}" == *"${dp}"* ]] && [[ "${pml}" == *"${pkg}"* ]] ; then
    # If this pkg is installed
    echo -e "\nDevice Info"
    echo "IP: `echo $dev | cut -d ':' -f 1`"
    echo "Device: `$dev | awk -F "$dp" '{print $2}'`"
    echo "Version Android: `adb shell getprop ro.build.version.release`"
    echo "SDK Version: `adb shell getprop ro.build.version.sdk`"

    echo -e "\nPackage Info"
    echo "Path APK: `adb shell pm path $pkg | cut -d ':' -f 2`"
    echo "Path Data: /data/data/$pkg"
    echo "Link Data: /data/user/0/$pkg"
fi