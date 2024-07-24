#!/bin/bash

if [ ! -d "${PWD}/.data/bin" ]; then
  # os & arch
  OS=$(uname -s | tr '[:upper:]' '[:lower:]' | sed 's/mingw64_nt.*/windows/')
  ARCH=$(uname -m | sed 's/x86_64/amd64/g' | sed 's/aarch64/arm64/g')
  PLATFORM=${OS}-${ARCH}
  PLATFORM=$(echo $PLATFORM | sed 's/darwin-arm64/darwin-amd64/g')

  # fabric versions
  VERSION="2.2.5"

  BINARY_FILE="hyperledger-fabric-${PLATFORM}-${VERSION}.tar.gz"
  URL="https://github.com/hyperledger/fabric/releases/download/v${VERSION}/${BINARY_FILE}"
  DEST_DIR="$(pwd)/.data"
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
fi

export PATH=${PATH}:${PWD}/.data/bin
export FABRIC_CFG_PATH=$PWD/config/

# imports
. scripts/utils.sh
. scripts/envVar.sh

setGlobals 1

SCFGOCC=${PWD}/../
MODULE=core
CHANNEL_ID=riverchain


#
# 1. GET SEQUENCE
#
SEQUENCE_STR=$(peer lifecycle chaincode querycommitted --channelID ${CHANNEL_ID} | grep -E 'Sequence: \d+' -o | grep -E '\d+' -o)
: ${SEQUENCE_STR:=0}
SEQUENCE=$((SEQUENCE_STR + 1))
println "executing with the following"
println "- Upcoming sequence: ${C_GREEN}${SEQUENCE}${C_RESET}"
if [[ -z $SEQUENCE_STR ]]; then
    errorln "No sequence found."
    exit 1
fi

#
# 1.2 GET VERSION
#
result=$(peer lifecycle chaincode querycommitted --channelID ${CHANNEL_ID} | grep ${MODULE})
HEAD_VERSION=$(awk -F, '{print $2}' <<< ${result})
HEAD_VERSION=$(awk -F'[^0-9]+' '{ print $2 }' <<< ${HEAD_VERSION})
VERSION=$((HEAD_VERSION))
VERSION=$((VERSION += 1))
VERSION="v$VERSION"
println "- Current version: ${C_GREEN}${HEAD_VERSION}${C_RESET}"
println "- Upcoming version: ${C_GREEN}${VERSION}${C_RESET}"

./scripts/deployCC.sh ${CHANNEL_ID} ${MODULE} ${SCFGOCC}cmd/core go ${VERSION} ${SEQUENCE} "" "" ${SCFGOCC}configs/collections.json 