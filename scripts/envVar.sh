#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. scripts/utils.sh

# parameters
BASE_DIR=${PWD}
# solve base if exeute on host machine
if [ -d ${PWD}/.data/organizations ]; then
  BASE_DIR=${PWD}/.data
fi

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${BASE_DIR}/organizations/ordererOrganizations/riverchain.com/orderers/orderer.riverchain.com/msp/tlscacerts/tlsca.riverchain.com-cert.pem
export PEER0_ORG1_CA=${BASE_DIR}/organizations/peerOrganizations/org1.riverchain.com/peers/peer0.org1.riverchain.com/tls/ca.crt
export PEER0_ORG2_CA=${BASE_DIR}/organizations/peerOrganizations/org2.riverchain.com/peers/peer0.org2.riverchain.com/tls/ca.crt
export ORDERER_TLS_HOST=orderer.riverchain.com

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${BASE_DIR}/organizations/peerOrganizations/org1.riverchain.com/users/Admin@org1.riverchain.com/msp
    export CORE_PEER_ADDRESS=host.docker.internal:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${BASE_DIR}/organizations/peerOrganizations/org2.riverchain.com/users/Admin@org2.riverchain.com/msp
    export CORE_PEER_ADDRESS=host.docker.internal:9051

  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container
setGlobalsCLI() {
  setGlobals $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_ADDRESS=peer0.org1.riverchain.com:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_ADDRESS=peer0.org2.riverchain.com:9051
  else
    errorln "ORG Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.org$1"
    ## Set peer addresses
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    ## Set path to TLS certificate
    TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_ORG$1_CA")
    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    # shift by one to get to the next organization
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
