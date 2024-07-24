#!/bin/bash

#
# install binary packages
#
REGISTRY=${FABRIC_DOCKER_REGISTRY:-docker.io/hyperledger}

# os & arch
OS=$(uname -s | tr '[:upper:]' '[:lower:]' | sed 's/mingw64_nt.*/windows/')
ARCH=$(uname -m | sed 's/x86_64/amd64/g' | sed 's/aarch64/arm64/g')
PLATFORM=${OS}-${ARCH}

# fabric & ca versions
VERSION="2.2.5"
CA_VERSION="1.5.2"

# Prior to fabric 2.5, use amd64 binaries on darwin-arm64
if [[ $VERSION =~ ^2\.[0-4]\.* ]]; then
    PLATFORM=$(echo $PLATFORM | sed 's/darwin-arm64/darwin-amd64/g')
fi

BINARY_FILE=hyperledger-fabric-${PLATFORM}-${VERSION}.tar.gz
CA_BINARY_FILE=hyperledger-fabric-ca-${PLATFORM}-${CA_VERSION}.tar.gz

# this will download the .tar.gz
download() {
    local BINARY_FILE=$1
    local URL=$2
    local DEST_DIR=$(pwd)
    echo "===> Downloading: " "${URL}"
    if [ -d fabric-loc-network ]; then
        DEST_DIR="fabric-loc-network"
    fi
    echo "===> Will unpack to: ${DEST_DIR}"
    curl -L --retry 5 --retry-delay 3 "${URL}" | tar xz -C ${DEST_DIR} || rc=$?
    if [ -n "$rc" ]; then
        echo "==> There was an error downloading the binary file."
        return 22
    else
        echo "==> Done."
    fi
}

echo "===> Downloading version ${VERSION} platform specific fabric binaries" 
download "${BINARY_FILE}" "https://github.com/hyperledger/fabric/releases/download/v${VERSION}/${BINARY_FILE}"
if [ $? -eq 22 ]; then
    echo
    echo "------> ${VERSION} platform specific fabric binary is not available to download <----"
    echo
    exit
fi

echo "===> Downloading version ${CA_VERSION} platform specific fabric-ca-client binary"
download "${CA_BINARY_FILE}" "https://github.com/hyperledger/fabric-ca/releases/download/v${CA_VERSION}/${CA_BINARY_FILE}"
if [ $? -eq 22 ]; then
    echo
    echo "------> ${CA_VERSION} fabric-ca-client binary is not available to download  (Available from 1.1.0-rc1) <----"
    echo
    exit
fi
