#!/bin/bash
# App Info JSON ~ Request To Google Play

if [ -z "$1" ]; then
    echo "App Info JSON ~ Request To Google Play"
    echo "Requirements:   python, google-play-scrapper"
    echo "Repository:     github.com/redrockstyle/apk_scripts"
    echo ""
    echo "Usage:          $0 <package.name> [lang] [country]"
    echo "Example:        $0 some.package.name en us"
    exit 0
fi

PKG="$1"
LANG="${2:-en}"
COUNTRY="${3:-us}"

python - <<PY
import sys, json
try:
    from google_play_scraper import app
except Exception as e:
    sys.stderr.write("Install dependency: pip install google-play-scraper\n")
    sys.exit(2)

pkg = "${PKG}"
lang = "${LANG}"
country = "${COUNTRY}"

try:
    info = app(pkg, lang=lang, country=country)
except Exception as e:
    print(json.dumps({"error": str(e)}, ensure_ascii=False))
    sys.exit(1)

out = {
    "package": pkg,
    "title": info.get("title"),
    "shortDescription": info.get("summary") or info.get("shortDescription") or None,
    "description": info.get("description"),
    "version": info.get("version"),               
    "versionCode": info.get("versionCode"),
    "requiredAndroid": info.get("androidVersion") or info.get("androidVersionText"),
    "updated": info.get("updated"),
    "size": info.get("size"),
    "installs": info.get("installs"),
    "minInstalls": info.get("minInstalls"),
    "score": info.get("score"),
    "ratings": info.get("ratings"),
    "developer": info.get("developer"),
    "developerEmail": info.get("developerEmail"),
    "privacyPolicy": info.get("privacyPolicy"),
    "offersIAP": info.get("offersIAP"),
    "adSupported": info.get("adSupported"),
    "url": "https://play.google.com/store/apps/details?id=" + pkg
}

print(json.dumps(out, ensure_ascii=False, indent=2))
PY
