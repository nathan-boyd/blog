#! /bin/bash

function withTime (){
    BLUE='\033[0;34m'
	NO_COLOR='\033[0m'
    echo -e "${BLUE}[$(date +%Y-%m-%d\ %H:%M:%S)]:${NO_COLOR} $*"
}

function logInfo (){
    GREEN='\033[0;32m'
	NO_COLOR='\033[0m'
    echo -e "${GREEN}[INFO]:${NO_COLOR} $*"
}
