#! /bin/bash

source ./scripts/util.sh

ISTAG=false
SEMVER=0.0.1

if grep -q '^tags/' <<< "$CHECKOUT"; then
    ISTAG=true
    SEMVER=$(echo "$CHECKOUT" | grep -oE "[0-9]+[.][0-9]+[.][0-9]+")
fi

log() {
    while read -r data; do
        if [ -n "$data" ]; then
            logDebug $data
        else
            echo ""
        fi
    done
}

build() {
    logInfo "Building image with tag $1"
    docker build . -t "nathanboyd/blog:$SEMVER"
}

publish() {
    if [ $ISTAG != true ]; then
        echo "Publish only from tag checkout; skipping"
        return
    fi
}

{
    logInfo "Tag is "\""$Tag"\"""
    logInfo "Semver is "\""$SEMVER"\"""

    logInfo "Starting Build Steps"
    build
    logInfo "Build Steps Complete"

    logInfo "Starring Publish Steps"
    publish
    logInfo "Publish Steps Complete"

} | log logDebug
