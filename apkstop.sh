#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo "Usage: appstop <appname.apk>"
    exit 1
fi

pkg=$(aapt dump badging $1|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
adb shell am force-stop $pkg
