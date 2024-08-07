#!/bin/bash

# Version
version="1.5.2"

# Init values
IFS=$'\n'
BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
app=''
v_flag=0
f_flag=0
d_flag=0
e_flag=0
s_flag=''
select_arg=( )
m_flag=0
path_adb='adb'
path_aapt='aapt'
path_apkanalyzer='apkanalyzer'
mnf=''

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
    echo -e "-f\tFind some.package.format in the root directory"
    echo -e "-d\tPrint device info"
    echo -e "-e\tShow non exported (exported=\"false\" in AndroidManifest.xml)"
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
print_yellow() {
    echo -e "$YELLOW$1$NC"
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

check_and_init_vars() {
    if [ -z $1 ] ; then
        print_verbose "Argument -a is required"
        print_usage;
        die;
    fi
    if ! test -f $1; then
        print_red "APK file does not exist"
        die
    fi
    if ! command -v adb &> /dev/null ; then
        if ! command -v "$HOME/Android/Sdk/platform-tools/adb" &> /dev/null ; then
            print_red "adb is not installed"
            print_red "Install platform-tools or add utils in the path"
            die
        else
            print_yellow "adb is not contained in the PATH"
            print_yellow "adb found in $HOME/Android/Sdk/platform-tools/adb"
            path_adb="$HOME/Android/Sdk/platform-tools/adb"
        fi
    fi
    if ! command -v aapt &> /dev/null
    then
        ver_aapt=$(find $HOME/Android/Sdk/build-tools/ -maxdepth 1  ! -path $HOME/Android/Sdk/build-tools/ -type d -printf '%T@ %P\n' | sort -n | head -n1 | awk '{print $2}')
        if ! command -v "$HOME/Android/Sdk/build-tools/${ver_aapt}/aapt" &> /dev/null ; then
            print_red "aapt is not installed"
            print_red "install cmdline-tools or add utils in the path"
            die
        else
            print_yellow "aapt is not contained in the PATH"
            print_yellow "aapt found in $HOME/Android/Sdk/build-tools/${ver_aapt}/aapt"
            path_aapt="$HOME/Android/Sdk/build-tools/${ver_aapt}/aapt"
        fi
    fi
    if ! command -v apkanalyzer &> /dev/null
    then
        if ! command -v "$HOME/Android/Sdk/cmdline-tools/latest/bin/apkanalyzer" &> /dev/null ; then
            print_red "apkanalyzer is not installed"
            print_red "Install build-tools or add utils in the path"
            die
        else
            print_yellow "apkanalyzer is not contained in the PATH"
            print_yellow "apkanalyzer found in $HOME/Android/Sdk/cmdline-tools/latest/bin/apkanalyzer"
            path_apkanalyzer="$HOME/Android/Sdk/cmdline-tools/latest/bin/apkanalyzer"
        fi
    fi
    if ! command -v xmlstarlet &> /dev/null
    then
        print_red "xmlstarlet is not installed"
        print_red "install: apt install xmlstarlet"
        die
    fi
    mnf=$($path_apkanalyzer -h manifest print "$1" 2>/dev/null)
    if [ $? -ne 0 ] ; then
        print_red "Invalid APK file"
        die
    fi
    if [[ "$s_flag" != '' ]] ; then
        select_arg=( -s "${s_flag}" )
    fi
}

print_package_info() {
    print_verbose "Get package info";
    print_verbose "Runtime: aapt dump badging ${1}";
    aapt_info=$($path_aapt dump badging $1)
    pkg=$(echo "${aapt_info}"|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
    act=$(echo "${aapt_info}"|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
    ver=$(echo "${aapt_info}"|awk -F" " '/package/ {print $4}'|awk -F"'" '/versionName=/ {print $2}')
    min_sdk_version=$(echo "${aapt_info}"|awk -F" " '/sdkVersion/ {print $1}'|awk -F"'" '{print $2}')
    target_sdk_version=$(echo "${aapt_info}"|awk -F" " '/targetSdkVersion/ {print $1}'|awk -F"'" '{print $2}')

    print_green "Package info"
    echo "Package Name: $pkg"
    echo "MainActivity: $act"
    echo "Version APK: $ver"
    echo "Minimal SDK: $min_sdk_version"
    echo "Target SDK: $target_sdk_version"
}

print_permissions() {
    print_verbose "\nParse aapt permissions"
    perm=$($path_aapt d permissions $1 | grep "permission:")
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
}

print_parsed_manifest_template() {
    print_green "$2 exported:"
    for LINE in $1
    do
        if [[ $(echo $LINE | cut -d ' ' -f 1) == "true" ]] ; then
            echo "`echo $LINE | cut -d ' ' -f 2`"
            if [[ $3 != "" ]] ; then
                param=$(echo $LINE | cut -d ' ' -f 3)
                if [[ "$param" != '' ]] ; then
                    echo -e "\t- $3: $param"
                fi
            fi
        fi
    done
    if [ $e_flag -eq 1 ] && [ $m_flag -eq 0 ] ; then
        print_green "$2 non exported:"
        for LINE in $1
        do
            if [[ $(echo $LINE | cut -d ' ' -f 1) == "false" ]] ; then
                echo "`echo $LINE | cut -d ' ' -f 2`"
                if [[ $3 != "" ]] ; then
                    param=$(echo $LINE | cut -d ' ' -f 3)
                    if [[ "$param" != '' ]] ; then
                        echo -e "\t- $3: $param"
                    fi
                fi
            fi
        done
    fi
}

print_parsed_manifest() {
    print_green "\nAnalyze AndroidManifest.xml"

    print_verbose "Execute: echo AndroidManifest.xml | xmlstarlet sel -t -m '//activity/intent-filter/data[@android:scheme and @android:host]' -v 'concat(@android:scheme, \"://\", @android:host, @android:pathPrefix, @android:path, @android:pathSufix)' -n | sort -uf"
    print_green "URL schemes:"
    shm_hosts=$(echo "${mnf}" | xmlstarlet sel -t -m '//activity/intent-filter/data[@android:scheme and @android:host]' -v 'concat(@android:scheme, "://", @android:host, @android:pathPrefix, @android:path, @android:pathSufix)' -n | sort -uf)
    echo "${shm_hosts}"

    print_verbose "Parse activeties"
    print_verbose "Execute: echo AndroidManifest.xml | xmlstarlet sel -t -m '//activity[@android:name and @android:exported]' -v 'concat(@android:exported, \" \", @android:name)' -n | sort -uf"
    shm_activeties=$(echo "${mnf}" | xmlstarlet sel -t -m '//activity[@android:name and @android:exported]' -v 'concat(@android:exported, " ", @android:name)' -n | sort -uf)
    print_parsed_manifest_template "$shm_activeties" "Activities" ""

    if [ $m_flag -eq 0 ] ; then
        print_verbose "Parse Activity-alias"
        print_verbose "Execute: echo AndroidManifest.xml | xmlstarlet sel -t -m '//activity-alias[@android:name and @android:exported]' -v 'concat(@android:name, \" AS targetActivity:\", @android:targetActivity)' -n | sort -uf"
        shm_activeties_alias=$(echo "${mnf}" | xmlstarlet sel -t -m '//activity-alias[@android:name and @android:exported]' -v 'concat(@android:name, " AS targetActivity:", @android:targetActivity)' -n | sort -uf)
        if [[ $shm_activeties_alias != "" ]] ; then
            print_green "Activity-alias (exported):"
            echo "${shm_activeties_alias}"
        fi
    fi

    print_verbose "Parse broadcast receivers"
    print_verbose "Execute: echo AndroidManifest.xml | xmlstarlet sel -t -m '//receiver[@android:name and @android:exported]' --if '//receiver[@android:permission]' -v 'concat(@android:exported, \" \", @android:name, \" \", @android:permission)' -n --else -v 'concat(@android:exported, \" \", @android:name)' -n | sort -uf"
    shm_receivers=$(echo "${mnf}" | xmlstarlet sel -t -m '//receiver[@android:name and @android:exported]' --if '//receiver[@android:permission]' -v 'concat(@android:exported, " ", @android:name, " ", @android:permission)' -n --else -v 'concat(@android:exported, " ", @android:name)' -n | sort -uf)
    print_parsed_manifest_template "$shm_receivers" "Broadcast receivers" "permission"

    print_verbose "Parse content providers"
    print_verbose "Execute: echo AndroidManifest.xml | xmlstarlet sel -t -m '//provider[@android:name and @android:exported and @android:authorities]' -v 'concat(@android:exported, \" \", @android:name, \" \", @android:authorities)' -n | sort -uf"
    shm_provides=$(echo "${mnf}" | xmlstarlet sel -t -m '//provider[@android:name and @android:exported and @android:authorities]' -v 'concat(@android:exported, " ", @android:name, " ", @android:authorities)' -n | sort -uf)
    print_parsed_manifest_template "$shm_provides" "Content providers" "authority"

    print_verbose "Parse services"
    print_verbose "Exucute: echo AndroidManifest.xml | xmlstarlet sel -t -m '//service[@android:name and @android:exported]' --if '//service[@android:permission]' -v 'concat(@android:exported, \" \", @android:name, \" \", @android:permission)' -n --else -v 'concat(@android:exported, \" \", @android:name)' -n | sort -uf"
    shm_services=$(echo "${mnf}" | xmlstarlet sel -t -m '//service[@android:name and @android:exported]' --if '//service[@android:permission]' -v 'concat(@android:exported, " ", @android:name, " ", @android:permission)' -n --else -v 'concat(@android:exported, " ", @android:name)' -n | sort -uf)
    print_parsed_manifest_template "$shm_services" "Serveces" "permission"
}

parse_misconf_template() {
    res=$2
    if [[ $(echo "${mnf}" | grep $1) != "" ]] ; then
        confs+=($1)
    fi
}

print_misconf() {
    print_green "App misconfigurations:"
    confs=()
    parse_misconf_template "android:allowBackup=\"true\""
    parse_misconf_template "android:debuggable=\"true\""
    parse_misconf_template "android:autoVerify=\"true\""
    parse_misconf_template "cleartextTrafficPermitted=\"true\""
    parse_misconf_template "usesCleartextTraffic=\"true\""
    len_confs=${#confs[@]}
    if [ $len_confs -ne 0 ] ; then
        for (( i=0; i<$len_confs; i++ )) ;
        do
            echo "${confs[i]}"
        done
    else
        print_green "Nothing"
    fi
}

print_directories() {
    if [ $m_flag -eq 0 ] ; then
        echo ""
        print_verbose "Find adb connections"
        dp="device product:"

        if [[ "$s_flag" == '' ]] ; then
            dev=$(${path_adb} devices -l 2>/dev/null | grep "$dp")
        else
            dev=$(${path_adb} devices -l 2>/dev/null | grep "$s_flag")
        fi
        if [ $? -ne 0 ] ; then
            print_verbose "No adb connections";
            die;
        fi
        dev_id=$(echo $dev | cut -d ':' -f 1)
        print_verbose "Device $dev_id is found"

        pml=$(${path_adb} "${select_arg[@]}" shell pm list package | grep $pkg)
        if [[ "${dev}" == *"${dp}"* ]] && [[ "${pml}" == *"${pkg}"* ]] ; then
            # If pkg is installed
            if [ $d_flag -eq 1 ] ; then
                print_verbose "Get info of device with adb "${select_arg[@]}" shell getprop"
                print_green "Device Info"
                echo "$(adb shell uname -a)"
                echo "ID: ${dev_id}"
                echo "Device: `echo $dev | awk -F "$dp" '{print $2}'`"
                echo "Version Android: `${path_adb} "${select_arg[@]}" shell getprop ro.build.version.release`"
                echo "SDK Version: `${path_adb} "${select_arg[@]}" shell getprop ro.build.version.sdk`"
                echo ""
            fi

            print_verbose "Get location info installed app"
            print_green "Package Info"
            env_data_path=$(${path_adb} shell echo \$ANDROID_DATA)
            data_path="$env_data_path/user/0"
            echo -e "BaseAPKPath:\t`${path_adb} "${select_arg[@]}" shell pm path $pkg | cut -d ':' -f 2`"

            real_data_path=$(${path_adb} shell realpath ${data_path})
            print_green "Link->RealDataPath: $data_path --> $real_data_path"
            echo -e "DataPath:\t$data_path/$pkg"
            echo -e "CachePath:\t$data_path/$pkg/cache"
            echo -e "CodeCachePath:\t$data_path/$pkg/code_cache"
            echo -e "FilesPath:\t$data_path/$pkg/files"

            link_ext_path=$(${path_adb} shell echo \$EXTERNAL_STORAGE)
            real_ext_path=$(${path_adb} shell realpath $link_ext_path)
            print_green "Link->RealExtStorage: $link_ext_path -> $real_ext_path"
            echo -e "ExtDataPath:\t$real_ext_path/Android/data/$pkg"
            echo -e "ExtObbPath:\t$real_ext_path/Android/obb/$pkg"

            if [ $f_flag -eq 1 ] ; then
                echo ""
                ${path_adb} "${select_arg[@]}" root 1>/dev/null
                if [ $? -eq 0 ] ; then
                    print_green "Find location $pkg in /"
                    echo "$(${path_adb} "${select_arg[@]}" shell find / -name "$pkg" 2>/dev/null)"
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
}

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

check_and_init_vars $app

print_package_info $app
print_permissions $app
print_parsed_manifest
print_misconf
print_directories
