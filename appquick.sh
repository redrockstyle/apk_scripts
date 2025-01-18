#!/bin/bash

# Version
version="1.7.3"

# Init values (default)
# Colors
IFS=$'\n'
BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
# Flags
v_flag=0
f_flag=0
d_flag=0
e_flag=0
i_flag=0
c_flag=0
s_flag=''
select_arg=( ) # device id
m_flag=0
# Path tools
path_adb='adb'
path_aapt='aapt'
path_apkanalyzer='apkanalyzer'
# Global vars
app=''
pkg=''
aapt_info=''
mnf=''
cmd_rand="tr -dc [:alnum:] < /dev/urandom | head -c 8"
workdir=''

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
    echo -e "Welcome to appquick!"
    echo -e "This is a small script for collecting information about the app"
    echo -e "Just put your package file or some.package.name :D"
    echo -e "Requirements:\taapt, adb, apkanalyzer, xmlstarlet, unzip"
    echo -e "Repository:\tgithub.com/redrockstyle/apk_scripts"
}
print_usage() {
    echo "Usage: appquick [-vfdeicmh] [-s <device_id>] -a <appname.apk>"
    echo -e "-a\tAPK/APKM/XAPK/APKS file or package.name.format"
    echo -e "-v\tVerbose mode"
    echo -e "-f\tFind some.package.format in the root directory"
    echo -e "-d\tPrint device info"
    echo -e "-e\tShow non exported (exported=\"false\" in AndroidManifest.xml)"
    echo -e "-s id\tSelect device id"
    echo -e "-i\tForce install/reinstall APK or Import base.apk (depending on -a)"
    echo -e "-c\tCleanup after exiting"
    echo -e "-m\tMinimal mode: print only basic info"
    echo -e "-h\tPrint usage"
    echo -e "-V\tPrint version"
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
print_green_echo_if_not_empty(){
    if [ "$2" != "" ] ; then
        print_green "$1"
        echo -e "$2"
    fi
}

is_inst_pkg() {
    if [[ $(${path_adb} "${select_arg[@]}" shell pm list package | grep $1) == *"$1"* ]] ; then
        return 1
    else
        return 0
    fi
}

is_base_apk() {
    if [[ $(echo "$1" | head -n 1 | grep "split") != "" ]] ; then
        return 1
    else
        return 0
    fi
}

get_aapt_dump() {
    print_verbose "Run aapt dump badging ${1}";
    aapt_info=$($path_aapt dump badging $1)
    if [ $? -ne 0 ] ; then
        print_red "File \"$1\" is not APK format"
        die
    fi
}
remove_if_exists() {
    is_inst_pkg $pkg
    res=$?
    if [[ ${res} -eq 1 ]] ; then
        print_yellow "Removing ${pkg}:"
        ${path_adb} ${select_arg[@]} shell pm uninstall $pkg
    fi
}

search_and_import() {
    pkg=$app
    print_verbose "Search package..."
    is_inst_pkg $pkg
    res=$?
    if [[ ${res} -eq 1 ]] ; then
        print_yellow "Package $pkg is found"
        if [ $i_flag -eq 1 ] ; then
            rand_suffix=$(echo -e $cmd_rand | bash)
            path_to_apk="$(${path_adb} ${select_arg[@]} shell pm path ${pkg} | awk -F':' '{print $2}')"
            cnt=$(echo -e "${path_to_apk}" | wc -l)

            if [ $cnt \> 1 ] ; then
                print_yellow "Detect split package"
                workdir="${pkg}-split-${rand_suffix}"
                mkdir "${workdir}"
                for LINE in ${path_to_apk}
                do
                    echo "Loading: ${LINE}..."
                    ${path_adb} ${select_arg[@]} pull "${LINE}" "${workdir}/${LINE##*/}" &> /dev/null
                done
                app="${workdir}/base.apk"
            else
                apk_mask="${pkg}-$rand_suffix"
                ${path_adb} ${select_arg[@]} pull "${path_to_apk}" "${apk_mask}-base.apk" &> /dev/null
                app="${apk_mask}-base.apk"
            fi


            if ! test -f $app; then
                print_red "Error load file"
                app=''
            else
                print_yellow "Base APK file has been saved in ${app}\n"
                aapt_info=$($path_aapt dump badging $app)
            fi
        else
            app=''
        fi
    else
        print_red "APK/APKM/XAPK/APKS file or package name is not found"
        die
    fi
}

extract_and_install() {
    if [ "${app: -4}" == ".apk" ] ; then
        get_aapt_dump ${app}
        if ! is_base_apk $aapt_info ; then
            print_red "File \"${app}\" is part of the \"split\" format"
            die
        fi

        pkg="$(echo "${aapt_info}"|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')"
        if [ $i_flag -eq 1 ] ; then
            remove_if_exists ${pkg}
            print_yellow "Install ${pkg}:"
            ${path_adb} ${select_arg[@]} install -r $app
            echo ""
        fi
    elif [ "${app: -5}" == ".xapk" ] || [ "${app: -5}" == ".XAPK" ] \
        || [ "${app: -5}" == ".apkm" ] || [ "${app: -5}" == ".APKM" ] \
        || [ "${app: -5}" == ".apks" ] || [ "${app: -5}" == ".APKS" ] ; then
        print_yellow "Detect split format"
        old_app=${app}
        rand_dir=$(echo -e $cmd_rand | bash)
        unzip $app -d $rand_dir &>/dev/null
        if [ $? -ne 0 ] ; then
            print_red "Error extract split package"
            die
        fi

        list_apk_files=$(ls -1 $rand_dir | grep "apk")
        app=''
        for LINE in $list_apk_files
        do
            echo -e "Extracted APK: ${LINE}"
            if is_base_apk $LINE ; then
                app=$LINE
                #break
            fi
        done

        if [ "$app" == '' ]; then
            print_red "Base APK file is not found"
            rm -rf $rand_dir
            die
        fi

        get_aapt_dump "${rand_dir}/${app}"
        pkg="$(echo "${aapt_info}"|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')"

        workdir="${pkg}-split-${rand_dir}"
        mv "${rand_dir}" "${workdir}"
        app="${workdir}/${app}"

        print_yellow "Packages has been saved in ${workdir}\n"

        if [ $i_flag -eq 1 ] ; then
            remove_if_exists ${pkg}

            print_yellow "Installing package ${old_app}..."
            print_verbose "Run command for install package: "${path_adb}" $(echo "${select_arg[@]}") install-multiple -r "${workdir}"/*.apk"
            ${path_adb} ${select_arg[@]} install-multiple -r ${workdir}/*.apk
            if [ $? -ne 0 ] ; then
                print_red "Install is failed";
            fi
        fi

        if [ "${old_app: -5}" == ".xapk" ] || [ "${old_app: -5}" == ".XAPK" ] ; then
            list_obb_files=$(ls -1 $rand_dir | grep "obb")
            if [ "${list_obb_files}" != "" ] ; then

                print_yellow "Detect OBB dir:"
                for LINE in $list_obb_files
                do
                    echo -e "${LINE}"
                done

                read -p "Do you want to move OBB in the mobile storage? (Y/n)" yn
                if [ "${yn}" != [Nn]*  ] ; then
                    print_yellow "Moving OBB..."
                    for LINE in $list_obb_files
                    do
                        echo -e "Move ${LINE} in /sdcard/Android/obb"
                        ${path_adb} ${select_arg[@]} push ${LINE} /sdcard/Android/obb/.
                    done
                else
                    print_yellow "OBB has been not moved"
                fi
            fi
        fi
    else
        print_red "Unsupported format file"
        die
    fi
}

check_and_init_vars() {
    if [ -z $1 ] ; then
        print_verbose "Argument -a is required"
        print_usage;
        die;
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

    if [[ "$s_flag" != '' ]] ; then
        select_arg=( -s ${s_flag} )
        print_verbose "ADB runtime as ${path_adb} $(echo "${select_arg[@]}")"
    fi

    if ! test -f $1; then
        print_verbose "File does not exist"
        search_and_import
    else
        print_verbose "File is found"
        extract_and_install
    fi

    mnf=$($path_apkanalyzer -h manifest print "$app" )
}

print_package_info() {
    print_verbose "Get package info";

    if [[ "${app}" != '' ]] ; then
        act=$(echo "${aapt_info}"|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
        ver=$(echo "${aapt_info}"|awk -F" " '/package/ {print $4}'|awk -F"'" '/versionName=/ {print $2}')
        min_sdk_version=$(echo "${aapt_info}"|awk -F" " '/sdkVersion/ {print $1}'|awk -F"'" '{print $2}')
        target_sdk_version=$(echo "${aapt_info}"|awk -F" " '/targetSdkVersion/ {print $1}'|awk -F"'" '{print $2}')
    elif [[ "${pkg}" != '' ]] ; then
        sdk_ver=$(${path_adb} ${select_arg[@]} shell dumpsys package ${pkg} | grep Sdk)

        act=$(${path_adb} ${select_arg[@]} shell dumpsys package ${pkg} | sed -n '/MAIN:/{n;p;}' | awk -F" " '{print $2}' | sed 's/\///')
        ver=$(${path_adb} ${select_arg[@]} shell dumpsys package ${pkg} | grep versionName | awk -F"=" '{print $2}')
        min_sdk_version=$(echo "${sdk_ver}" | awk -F"=" '{print $3}' | awk -F" " '{print $1}')
        target_sdk_version=$(echo "${sdk_ver}" | awk -F"=" '{print $4}')
    else
        print_red "Error parse basic info: package or filename is not defined"
        return
    fi

    print_green "Basic info"
    echo "Package Name: $pkg"
    echo "MainActivity: $act"
    echo "Version APK: $ver"
    echo "Minimal SDK: $min_sdk_version"
    echo "Target SDK: $target_sdk_version"
}

print_permissions() {
    print_verbose "Get permissions..."

    if [[ "${app}" != '' ]] ; then
        print_verbose "Parse permissions via aapt"

        perm=$($path_aapt d permissions $app | grep "permission:")
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
    elif [[ "${pkg}" != '' ]] ; then
        print_verbose "Parse permissions via dumpsys"

        print_green "Permissions:"
        echo -e "$(${path_adb} ${select_arg[@]} shell dumpsys package ${pkg} | sed -n '/declared permissions:/,/User /p' | sed  -e '$ d')"
    else
        print_red "Error parse permissions: package or filename is not defined"
    fi
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
    if [[ "${app}" == '' ]] ; then
        print_verbose "Filename for parse AndroidManifest.xml is not defined"
        return
    fi

    print_green "Analyze AndroidManifest.xml"

    print_verbose "Execute: echo AndroidManifest.xml | xmlstarlet sel -t -m '//activity/intent-filter/data[@android:scheme and @android:host]' -v 'concat(@android:scheme, \"://\", @android:host, @android:pathPrefix, @android:path, @android:pathSufix)' -n | sort -uf"
    shm_hosts=$(echo "${mnf}" | xmlstarlet sel -t -m '//activity/intent-filter/data[@android:scheme and @android:host]' -v 'concat(@android:scheme, "://", @android:host, @android:pathPrefix, @android:path, @android:pathSufix)' -n | sort -uf)
    print_green_echo_if_not_empty "URL schemes:" "${shm_hosts}"

    print_verbose "Parse activeties"
    print_verbose "Execute: echo AndroidManifest.xml | xmlstarlet sel -t -m '//activity[@android:name and @android:exported]' -v 'concat(@android:exported, \" \", @android:name)' -n | sort -uf"
    shm_activeties=$(echo "${mnf}" | xmlstarlet sel -t -m '//activity[@android:name and @android:exported]' -v 'concat(@android:exported, " ", @android:name)' -n | sort -uf)
    print_parsed_manifest_template "$shm_activeties" "Activities" ""

    print_verbose "Parse Activity-alias"
    print_verbose "Execute: echo AndroidManifest.xml | xmlstarlet sel -t -m '//activity-alias[@android:name and @android:exported]' -v 'concat(@android:name, \" AS targetActivity:\", @android:targetActivity)' -n | sort -uf"
    shm_activeties_alias=$(echo "${mnf}" | xmlstarlet sel -t -m '//activity-alias[@android:name and @android:exported]' -v 'concat(@android:name, " AS targetActivity:", @android:targetActivity)' -n | sort -uf)
    print_green_echo_if_not_empty "Activity-alias (exported):" "${shm_activeties_alias}"

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
    if [[ "${app}" == '' ]] ; then
        print_verbose "Filename for parse misconf is not defined"
        return
    fi

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
    if [[ "${pkg}" == '' ]] ; then
        print_verbose "Package for parse directories is not defined"
        return
    fi

    print_verbose "Get location info installed app"
    print_green "Directory Info"
    env_data_path=$(${path_adb} ${select_arg[@]} shell echo \$ANDROID_DATA)
    data_path="$env_data_path/user/0"
    echo -e "BaseAPKPath:\t`${path_adb} "${select_arg[@]}" shell pm path $pkg | cut -d ':' -f 2`"

    real_data_path=$(${path_adb} ${select_arg[@]} shell realpath ${data_path})
    print_green "Link->RealDataPath: $data_path --> $real_data_path"
    echo -e "DataPath:\t$real_data_path/$pkg"
    echo -e "CachePath:\t$real_data_path/$pkg/cache"
    echo -e "CodeCachePath:\t$real_data_path/$pkg/code_cache"
    echo -e "FilesPath:\t$real_data_path/$pkg/files"

    link_ext_path=$(${path_adb} ${select_arg[@]} shell echo \$EXTERNAL_STORAGE)
    real_ext_path=$(${path_adb} ${select_arg[@]} shell realpath $link_ext_path)
    print_green "Link->RealExtStorage: $link_ext_path -> $real_ext_path"
    echo -e "ExtDataPath:\t$real_ext_path/Android/data/$pkg"
    echo -e "ExtObbPath:\t$real_ext_path/Android/obb/$pkg"

    if [ $f_flag -eq 1 ] ; then
        echo ""
        ${path_adb} "${select_arg[@]}" root &>/dev/null
        print_green "Find location $pkg in /"
        if [ $? -eq 0 ] ; then
            ${path_adb} "${select_arg[@]}" shell find / -name "$pkg" 2>/dev/null
            ${path_adb} ${select_arg[@]} unroot &>/dev/null
        else
            print_red "Error find: ADB root restart failed"
        fi
    fi
}

print_device() {
    print_verbose "Get info of device with adb $(echo "${select_arg[@]}") shell getprop"
    print_green "Device Info"
    echo "$(${path_adb} "${select_arg[@]}" shell uname -a)"
    echo "ID: ${dev_id}"
    echo "Device: `echo $dev | awk -F "$dp" '{print $2}'`"
    echo "Version Android: `${path_adb} "${select_arg[@]}" shell getprop ro.build.version.release`"
    echo "SDK Version: `${path_adb} "${select_arg[@]}" shell getprop ro.build.version.sdk`"
}

cleanup() {
    if [ "${workdir}" != '' ] && [ ${c_flag} -eq 1 ] ; then
        print_yellow "\nRemoving directory $workdir..."
        rm -rf $workdir
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
while getopts 'a:vfdeics:mhV' flag; do
  case "${flag}" in
    a) app="${OPTARG}" ;;
    v) v_flag=1 ;;
    f) f_flag=1 ;;
    d) d_flag=1 ;;
    e) e_flag=1 ;;
    i) i_flag=1 ;;
    c) c_flag=1 ;;
    s) s_flag="${OPTARG}" ;;
    m) m_flag=1 ;;
    V) echo $version
       die ;;
    h) print_usage
       die ;;
    *) print_usage
       die ;;
  esac
done

check_and_init_vars $app

print_package_info
if [ $d_flag -eq 1 ] ; then
    echo ""
    print_device
fi
if [ $m_flag -eq 0 ] ; then
    echo ""
    print_permissions

    echo ""
    print_parsed_manifest

    echo ""
    print_misconf

    echo ""
    print_directories
else
    print_verbose "Minimal mode: print only base info"
fi
cleanup
