#! /bin/bash

function withTime (){
    BLUE='\033[0;34m'
	NO_COLOR='\033[0m'
    echo -e "${BLUE}[$(date +%Y-%m-%d\ %H:%M:%S)]:${NO_COLOR} $*"
}

function logWarn (){
    GREEN='\033[0;33m'
	NO_COLOR='\033[0m'
    echo -e "${GREEN}[INFO]:${NO_COLOR} $*"
}

function logErr (){
    RED='\033[0;91m'
	NO_COLOR='\033[0m'
    echo -e "${RED}[ERRO]:${NO_COLOR} $*"
}

function logInfo (){
    GREEN='\033[0;32m'
	NO_COLOR='\033[0m'
    echo -e "${GREEN}[INFO]:${NO_COLOR} $*"
}
