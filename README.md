# APK Scripts

Helper-tools for testing Android applications

## Requirements
For proper operation, you need:
- Android SDK installed
- An Android device connected via `adb connect`

## Install / Uninstall
`sudo bash install.sh` / `sudo bash uninstall.sh`

## Tools

<h2 align="center">AppQuick: Quick App Analysis</h2>
<p align="center"><img src="./img/appquick.png" /></p>

<h2 align="center">AppRun: Quick Runtime Actions</h2>
<p align="center"><img src="./img/apprun.png" /></p>

## Versions

### AppQuick
#### Version 1.7.3
- **Added formats support**: XAPK (APK-Pure), APKM (APK-Mirror), APKS (SAI)
- **Autoinstall and autoimport**: Added for XAPK, APKM, and APKS
- **Cleanup feature**: Added with argument `-c`

#### Version 1.6.3
- **Fixed importing multiple APK files**
- **Corrected unload behavior**: Now properly handles cases when adb has no connections

#### Version 1.6.2
- **Added APK/package selection**: Use argument `-a` to specify APK or package name
- **Autoinstall app**: Use argument `-i` with `-a some.apk`
- **Autoimport base.apk**: Use argument `-i` with `-a some.package.name`

### AppRun
#### Version 1.2.3
- **Improved logcat handling**: Now considers Android SDK version when running
