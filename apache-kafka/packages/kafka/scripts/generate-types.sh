#!/bin/bash -e

MODULE_NAME=core
BUILD_FOLDER=dist

PROTOCOLS_PATH=src/$MODULE_NAME/protocols
OUTPUT_PATH=./$BUILD_FOLDER/$MODULE_NAME/types
TEMP_PATH=./.temp

PACKAGE_MANAGER_ERROR="Unsupported package manager. Available options: 'npm', 'maven'."

AVRO_TOOLS_PACKAGE_MANAGER=maven
AVRO_TOOLS_REPO=https://repo1.maven.org/maven2/org/apache/avro/avro-tools
AVRO_TOOLS_VERSION=1.11.3
AVRO_TOOLS_PACKAGE=avro-tools-${AVRO_TOOLS_VERSION}.jar
AVRO_TOOLS_URL=$AVRO_TOOLS_REPO/$AVRO_TOOLS_VERSION/$AVRO_TOOLS_PACKAGE
AVRO_TOOLS_DOWNLOAD_PATH=$HOME/$AVRO_TOOLS_PACKAGE

CONVERTER_PACKAGE_MANAGER=npm
CONVERTER_PACKAGE_VERSION=3.6.0
CONVERTER_PACKAGE=@ovotech/avro-ts-cli
CONVERTER_AVSC_FILE_EXTENSION=avsc
CONVERTER_TS_FILE_EXTENSION=ts

prepare() {
    echo "Preparing output folders..."

    mkdir -p $TEMP_PATH
    mkdir -p $OUTPUT_PATH

    echo "Successfully prepared output folders!"
}

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

getAVROToolsPackage() {
    echo "Downloading $AVRO_TOOLS_PACKAGE..."

    curl -o $AVRO_TOOLS_DOWNLOAD_PATH -O $AVRO_TOOLS_URL

    echo "Successfully downloaded $AVRO_TOOLS_PACKAGE!"
}

getConverterPackage() {
    echo "Downloading $CONVERTER_PACKAGE..."

    npm i -g $CONVERTER_PACKAGE@$CONVERTER_PACKAGE_VERSION

    echo "Successfully downloaded $CONVERTER_PACKAGE!"
}

convertAVDLtoAVSC() {
    echo "Converting AVDL to AVSC..."

    if ! is_package_installed $AVRO_TOOLS_PACKAGE_MANAGER $AVRO_TOOLS_PACKAGE; then
        getAVROToolsPackage
    fi

    local protocols=$(ls $PROTOCOLS_PATH)

    for protocol in $protocols; do
        java -jar $AVRO_TOOLS_DOWNLOAD_PATH idl2schemata $PROTOCOLS_PATH/$protocol
        mv ./*.$CONVERTER_AVSC_FILE_EXTENSION $TEMP_PATH
    done

    echo "Succesfully converted AVDL to AVSC!"
}

generateTSfromAVSC() {
    echo "Generating TypeScript types..."

    if ! is_package_installed $CONVERTER_PACKAGE_MANAGER $CONVERTER_PACKAGE; then
        getConverterPackage
    fi

    local schemas=$(ls $TEMP_PATH/*.$CONVERTER_AVSC_FILE_EXTENSION)

    for schema in $schemas; do
        avro-ts $schema --output-dir $TEMP_PATH
    done

    echo "Successfully generated TypeScript types at $TEMP_PATH!"
}

cleanup() {
    echo "Cleaning up files and $TEMP_PATH folder..."

    for file in $TEMP_PATH/*.$CONVERTER_TS_FILE_EXTENSION; do
        mv -- $file "${file%.$CONVERTER_AVSC_FILE_EXTENSION.$CONVERTER_TS_FILE_EXTENSION}.$CONVERTER_TS_FILE_EXTENSION"
    done

    mv $TEMP_PATH/*.$CONVERTER_TS_FILE_EXTENSION $OUTPUT_PATH

    rm -rf $TEMP_PATH

    echo "Successfully cleaned up files and $TEMP_PATH folder!"
}

generateTypes() {
    echo "Generating types..."

    prepare
    convertAVDLtoAVSC
    generateTSfromAVSC
    cleanup

    echo "Successfully generated types!"
}

generateTypes
