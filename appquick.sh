#!/bin/bash

# Version
version="1.0.0"

# Init values
IFS=$'\n'
BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
app=''
v_flag=0
f_flag=0
d_flag=0
e_flag=0
s_flag=''
select_arg=( )
m_flag=0

# Defines functions
die() { exit 1; }
print_version() {
    echo -e "Version:\t$version\n"
}
print_logo1() {
    echo " ▄▄▄       ██▓███   ██▓███    █████   █    ██  ██▓ ▄████▄   ██ ▄█▀"
    echo "▒████▄    ▓██░  ██▒▓██░  ██▒▒██▓  ██▒ ██  ▓██▒▓██▒▒██▀ ▀█   ██▄█▒ "
    echo "▒██  ▀█▄  ▓██░ ██▓▒▓██░ ██▓▒▒██▒  ██░▓██  ▒██░▒██▒▒▓█    ▄ ▓███▄░ "
    echo "░██▄▄▄▄██ ▒██▄█▓▒ ▒▒██▄█▓▒ ▒░██  █▀ ░▓▓█  ░██░░██░▒▓▓▄ ▄██▒▓██ █▄ "
    echo " ▓█   ▓██▒▒██▒ ░  ░▒██▒ ░  ░░▒███▒█▄ ▒▒█████▓ ░██░▒ ▓███▀ ░▒██▒ █▄"
    echo " ▒▒   ▓▒█░▒▓▒░ ░  ░▒▓▒░ ░  ░░░ ▒▒░ ▒ ░▒▓▒ ▒ ▒ ░▓  ░ ░▒ ▒  ░▒ ▒▒ ▓▒"
    echo "  ▒   ▒▒ ░░▒ ░     ░▒ ░      ░ ▒░  ░ ░░▒░ ░ ░  ▒ ░  ░  ▒   ░ ░▒ ▒░"
    echo "  ░   ▒   ░░       ░░          ░   ░  ░░░ ░ ░  ▒ ░░        ░ ░░ ░ "
    echo "      ░  ░                      ░       ░      ░  ░ ░      ░  ░   "
    echo "                                                  ░               "
}
print_logo2() {
    echo "           _ __    _ __   __ _              _              _     "
    echo "  __ _    | '_ \  | '_ \ / _\` |   _  _     (_)     __     | |__  "
    echo " / _\` |   | .__/  | .__/ \__, |  | +| |    | |    / _|    | / /  "
    echo " \__,_|   |_|__   |_|__   __|_|   \_,_|   _|_|_   \__|_   |_\_\   "
    echo "_|\"\"\"\"\"|_|\"\"\"\"\"|_|\"\"\"\"\"|_|\"\"\"\"\"|_|\"\"\"\"\"|_|\"\"\"\"\"|_|\"\"\"\"\"|_|\"\"\"\"\"|  "
    echo "\"\`-0-0-'\"\`-0-0-'\"\`-0-0-'\"\`-0-0-'\"\`-0-0-'\"\`-0-0-'\"\`-0-0-'\"\`-0-0-'  "
}
print_logo3() {
    echo " ______     ______   ______   ______     __  __     __     ______     __  __    "
    echo "/\  __ \   /\  == \ /\  == \ /\  __ \   /\ \/\ \   /\ \   /\  ___\   /\ \/ /    "
    echo "\ \  __ \  \ \  _-/ \ \  _-/ \ \ \/\_\  \ \ \_\ \  \ \ \  \ \ \____  \ \  _\"-.  "
    echo " \ \_\ \_\  \ \_\    \ \_\    \ \___\_\  \ \_____\  \ \_\  \ \_____\  \ \_\ \_\ "
    echo "  \/_/\/_/   \/_/     \/_/     \/___/_/   \/_____/   \/_/   \/_____/   \/_/\/_/ "
    echo "                                                                                "
}
print_prolog() {
    echo -e "A little extractor for APK packages"
    echo -e "Just give your APK file :D"
    echo -e "Requirements:\taapt, adb, apkanalyzer, xmlstarlet"
    echo -e "Repository:\tgithub.com/redrockstyle/apk_scripts"
}
print_usage() {
    echo "Usage: appquick [-vfdemh] [-s <device_id>] -a <appname.apk>"
    echo -e "-a\tSelect APK file"
    echo -e "-v\tVerbose mode"
    echo -e "-f\tFind some.package.format in the /data folder"
    echo -e "-d\tPrint device info"
    echo -e "-e\tPrint only exported (exported=\"true\" in AndroidManifest.xml)"
    echo -e "-s id\tSelect device id"
    echo -e "-m\tMinimal mode (wo connect to device and print only exported=\"true\")"
    echo -e "-h\tPrint logo and usage"
}
print_random_logo(){
    rand_val=$((1 + $RANDOM % 3))
    rand_col=$((1 + $RANDOM % 3))
    case $rand_col in
        1) echo -e $RED ;;
        2) echo -e $GREEN ;;
        3) echo -e $BLUE ;;
    esac
    case $rand_val in
        1) print_logo1 ;;
        2) print_logo2 ;;
        3) print_logo3 ;;
    esac
    echo -e $NC
}
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

if ! command -v adb &> /dev/null ; then
    # TODO get dynamic PATH from ADNROID_SDK variable
    print_red "adb is not installed"
    echo "Install platform-tools or add utils in the path"
    die
fi
if ! command -v aapt &> /dev/null
then
    # TODO get dynamic PATH from ADNROID_SDK variable
    print_red "aapt is not installed"
    die
fi
if ! command -v apkanalyzer &> /dev/null
then
    # TODO get dynamic PATH from ADNROID_SDK variable
    print_red "apkanalyzer is not installed"
    die
fi
if ! command -v xmlstarlet &> /dev/null
then
    print_red "xmlstarlet is not installed"
    die
fi

# Check null args
if [[ $# -eq 0 ]] ; then
    print_random_logo
    print_prolog
    print_version
    print_usage
    die;
fi

# Parse args
while getopts 'a:vfdes:mh' flag; do
  case "${flag}" in
    a) app="${OPTARG}" ;;
    v) v_flag=1 ;;
    f) f_flag=1 ;;
    d) d_flag=1 ;;
    e) e_flag=1 ;;
    s) s_flag="${OPTARG}" ;;
    m) m_flag=1 ;;
    h) print_usage
       die ;;
    *) print_usage
       die ;;
  esac
done

# Check requred appname
if [ -z $app ] ; then
    print_verbose "Argument -a is required"
    print_usage;
    die;
fi

if [[ "$s_flag" != '' ]] ; then
    select_arg=( -s "${s_flag}" )
fi

# Static info
print_verbose "Get package info";
print_verbose "Runtime: aapt dump badging ${app}";
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

# Parse AndroidManifest.xml
print_green "\nAnalyze AndroidManifest.xml"
mnf=$(apkanalyzer -h manifest print "$app")

print_green "URL schemes:"
shm_hosts=$(echo "${mnf}" | xmlstarlet sel -t -m '//activity/intent-filter/data[@android:scheme and @android:host]' -v 'concat(@android:scheme, "://", @android:host, @android:pathPrefix, @android:path, @android:pathSufix)' -n | sort -uf)
echo "${shm_hosts}"

print_verbose "Parse activeties"
shm_activeties=$(echo "${mnf}" | xmlstarlet sel -t -m '//activity[@android:name and @android:exported]' -v 'concat(@android:exported, " ", @android:name)' -n)
print_green "Activities exported:"
for LINE in $shm_activeties
do
    if [[ $(echo $LINE | cut -d ' ' -f 1) == "true" ]] ; then
        echo "`echo $LINE | cut -d ' ' -f 2`"
    fi
done
if [ $e_flag -eq 0 ] && [ $m_flag -eq 0 ] ; then
    print_green "Activities non exported:"
    for LINE in $shm_activeties
    do
        if [[ $(echo $LINE | cut -d ' ' -f 1) == "false" ]] ; then
            echo "`echo $LINE | cut -d ' ' -f 2`"
        fi
    done
fi
if [ $m_flag -eq 0 ] ; then
    print_green "Activity-alias (exported):"
    shm_activeties_alias=$(echo "${mnf}" | xmlstarlet sel -t -m '//activity-alias[@android:name and @android:exported]' -v 'concat(@android:name, " AS targetActivity:", @android:targetActivity)' -n)
    echo "${shm_activeties_alias}"
fi

print_verbose "Parse broadcast receivers"
shm_receivers=$(echo "${mnf}" | xmlstarlet sel -t -m '//receiver[@android:name and @android:exported]' --if '//receiver[@android:permission]' -v 'concat(@android:exported, " ", @android:name, " ", @android:permission)' -n --else -v 'concat(@android:exported, " ", @android:name)' -n)
print_green "Broadcast receivers exported:"
for LINE in $shm_receivers
do
    if [[ $(echo $LINE | cut -d ' ' -f 1) == "true" ]] ; then
        echo "`echo $LINE | cut -d ' ' -f 2`"
        permis=$(echo $LINE | cut -d ' ' -f 3)
        if [[ "$permis" != '' ]] ; then
            echo -e "\t- permission: $permis"
        fi
    fi
done
if [ $e_flag -eq 0 ] && [ $m_flag -eq 0 ] ; then
    print_green "Broadcast receivers non exported:"
    for LINE in $shm_receivers
    do
        if [[ $(echo $LINE | cut -d ' ' -f 1) == "false" ]] ; then
            echo "`echo $LINE | cut -d ' ' -f 2`"
            permis=$(echo $LINE | cut -d ' ' -f 3)
            if [[ "$permis" != '' ]] ; then
                echo -e "\t- permission: $permis"
            fi
        fi
    done
fi

print_verbose "Parse content providers"
shm_provides=$(echo "${mnf}" | xmlstarlet sel -t -m '//provider[@android:name and @android:exported and @android:authorities]' -v 'concat(@android:exported, " ", @android:name, " ", @android:authorities)' -n)
print_green "Content providers exported:"
for LINE in $shm_provides
do
    if [[ $(echo $LINE | cut -d ' ' -f 1) == "true" ]] ; then
        echo "`echo $LINE | cut -d ' ' -f 2`"
        auth=$(echo $LINE | cut -d ' ' -f 3)
        if [[ "$auth" != '' ]] ; then
            echo -e "\t- authority: $auth"
        fi
    fi
done
if [ $e_flag -eq 0 ] && [ $m_flag -eq 0 ] ; then
    print_green "Content providers non exported:"
    for LINE in $shm_provides
    do
        if [[ $(echo $LINE | cut -d ' ' -f 1) == "false" ]] ; then
            echo "`echo $LINE | cut -d ' ' -f 2`"
            auth=$(echo $LINE | cut -d ' ' -f 3)
            if [[ "$auth" != '' ]] ; then
                echo -e "\t- authority: $auth"
            fi
        fi
    done
fi

print_verbose "Parse services"
shm_services=$(echo "${mnf}" | xmlstarlet sel -t -m '//service[@android:name and @android:exported]' --if '//service[@android:permission]' -v 'concat(@android:exported, " ", @android:name, " ", @android:permission)' -n --else -v 'concat(@android:exported, " ", @android:name)' -n)
print_green "Serveces exported"
for LINE in $shm_services
do
    if [[ $(echo $LINE | cut -d ' ' -f 1) == "true" ]] ; then
        echo "`echo $LINE | cut -d ' ' -f 2`"
        permis=$(echo $LINE | cut -d ' ' -f 3)
        if [[ "$permis" != '' ]] ; then
            echo -e "\t- permission: $permis"
        fi
    fi
done
if [ $e_flag -eq 0 ] && [ $m_flag -eq 0 ] ; then
    print_green "Services non exported:"
    for LINE in $shm_services
    do
        if [[ $(echo $LINE | cut -d ' ' -f 1) == "false" ]] ; then
            echo "`echo $LINE | cut -d ' ' -f 2`"
            permis=$(echo $LINE | cut -d ' ' -f 3)
            if [[ "$permis" != '' ]] ; then
                echo -e "\t- permission: $permis"
            fi
        fi
    done
fi

if [ $m_flag -eq 0 ] ; then
    echo ""
    print_verbose "Find device connection"
    dp="device product:"

    if [[ "$s_flag" == '' ]] ; then
        dev=$(adb devices -l 2>/dev/null | grep "$dp")
    else
        dev=$(adb devices -l 2>/dev/null | grep "$s_flag")
    fi
    if [ $? -ne 0 ] ; then
        print_verbose "No device connections";
        die;
    fi
    dev_id=$(echo $dev | cut -d ':' -f 1)
    print_verbose "Device $dev_id is found"

    pml=$(adb "${select_arg[@]}" shell pm list package | grep $pkg)
    if [[ "${dev}" == *"${dp}"* ]] && [[ "${pml}" == *"${pkg}"* ]] ; then
        # If this pkg is installed
        if [ $d_flag -eq 1 ] ; then
            echo ""
            print_verbose "Get info of device with adb "${select_arg[@]}" shell getprop"
            print_green "Device Info"
            echo "ID: ${dev_id}"
            echo "Device: `echo $dev | awk -F "$dp" '{print $2}'`"
            echo "Version Android: `adb "${select_arg[@]}" shell getprop ro.build.version.release`"
            echo "SDK Version: `adb "${select_arg[@]}" shell getprop ro.build.version.sdk`"
        fi

        print_verbose "Get location info installed app"
        print_green "Package Info"
        echo "Path APK: `adb "${select_arg[@]}" shell pm path $pkg | cut -d ':' -f 2`"
        echo "Path Data: /data/data/$pkg"
        echo "Link Data: /data/user/0/$pkg"

        if [ $f_flag -eq 1 ] ; then
            echo ""
            adb "${select_arg[@]}" root 1>/dev/null
            if [ $? -eq 0 ] ; then
                print_green "Find location $pkg in /"
                echo "$(adb "${select_arg[@]}" shell find / -name "$pkg" 2>/dev/null)"
            else
                print_verbose "ADB root restart failed"
            fi
        fi
    else
        print_verbose "Package $pkg is not installed on $dev_id"
    fi
else
    print_verbose "Minimal mode: Ignore adb connection"
fi




