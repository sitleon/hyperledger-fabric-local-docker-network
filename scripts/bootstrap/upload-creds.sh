#!/bin/bash

while :; do
    if [ ! -f "${WORK_DIR}/organizations/peerOrganizations/org1.riverchain.com/connection-org1.yaml" ]; then
        sleep 1
    else
        break
    fi
done

# upload the conn yaml file to awslocal
awslocal secretsmanager create-secret --name=connectionYaml --secret-string=file://${WORK_DIR}/organizations/peerOrganizations/org1.riverchain.com/connection-org1.yaml


while :; do
    if [ ! -f "${WORK_DIR}/organizations/fabric-ca/org1/ca-cert.pem" ]; then
        sleep 1
    else
        break
    fi
done

# upload the tls-cert file to awslocal 
awslocal secretsmanager create-secret --name=tlsCert --secret-string=file://${WORK_DIR}/organizations/fabric-ca/org1/ca-cert.pem

while :; do
    if [ ! -f "${WORK_DIR}/organizations/peerOrganizations/org1.riverchain.com/msp/signcerts/cert.pem" ]; then
        sleep 1
    else
        break
    fi
done

# upload the cert file to awslocal
awslocal secretsmanager create-secret --name=certificate --secret-string=file://${WORK_DIR}/organizations/peerOrganizations/org1.riverchain.com/msp/signcerts/cert.pem

PIV_KEY_PATH=""
for fname in "${WORK_DIR}/organizations/peerOrganizations/org1.riverchain.com/msp/keystore"/*
do
   PIV_KEY_PATH=${fname}
  break
done

# upload the piv key file to awslocal
awslocal secretsmanager create-secret --name=privateKey --secret-string=file://${PIV_KEY_PATH}
