#!/bin/bash
export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false

. scripts/utils.sh

if [ -f "system-genesis-block/genesis.block" ]; then
    warnln "Skip to create ca-cert & genesis block"
    exit 0
fi

# create ca certificate
. scripts/bootstrap/build-ca-cert.sh
# create genesis block for system channel
. scripts/bootstrap/create-genesis-blk.sh
