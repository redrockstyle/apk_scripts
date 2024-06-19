#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo "Usage: appinst <appname.apk>"
    exit 1
fi

adb install -r $1
