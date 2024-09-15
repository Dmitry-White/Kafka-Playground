#!/bin/bash -e

PACKAGE_MANAGER_ERROR="Unsupported package manager. Available options: 'npm', 'maven'."

AVRO_TOOLS_PACKAGE_MANAGER=maven
AVRO_TOOLS_VERSION=1.11.3
AVRO_TOOLS_PACKAGE=avro-tools-${AVRO_TOOLS_VERSION}.jar
AVRO_TOOLS_DOWNLOAD_PATH=$HOME/$AVRO_TOOLS_PACKAGE

CONVERTER_PACKAGE_MANAGER=npm
CONVERTER_PACKAGE=@ovotech/avro-ts-cli

is_package_installed() {
    local package_manager=$1
    local package=$2
    local handler=""

    case $package_manager in
    npm) handler="is_npm_package_installed $package" ;;
    maven) handler="is_maven_package_installed $package" ;;
    *) echo $PACKAGE_MANAGER_ERROR && exit 1 ;;
    esac

    echo "Checking if $package_manager $package is installed..."

    if $handler; then
        echo "$package is installed globally."
        return 0
    else
        echo "$package is not installed globally."
        return 1
    fi
}

is_npm_package_installed() {
    local package=$1

    if npm list -g --depth=0 $package >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

is_maven_package_installed() {
    local package=$1

    if [ -f $HOME/$package ]; then
        return 0
    else
        return 1
    fi
}

removeAVROToolsPackage() {
    echo "Cleaning global $AVRO_TOOLS_PACKAGE..."

    rm -rf $AVRO_TOOLS_DOWNLOAD_PATH

    echo "Successfully cleaned global $AVRO_TOOLS_PACKAGE!"
}

removeConverterPackage() {
    echo "Cleaning global $CONVERTER_PACKAGE..."

    npm remove -g $CONVERTER_PACKAGE

    echo "Successfully cleaned global $CONVERTER_PACKAGE!"
}

cleanGlobals() {
    echo "Cleaning globals..."

    if is_package_installed $AVRO_TOOLS_PACKAGE_MANAGER $AVRO_TOOLS_PACKAGE; then
        removeAVROToolsPackage
    fi

    if is_package_installed $CONVERTER_PACKAGE_MANAGER $CONVERTER_PACKAGE; then
        removeConverterPackage
    fi

    echo "Successfully cleaned globals!"
}

cleanGlobals
