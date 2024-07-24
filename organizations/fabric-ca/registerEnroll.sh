#!/bin/bash

function createOrg1() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/org1.riverchain.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.riverchain.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@host.docker.internal:7054 --caname ca-org1 --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/host-docker-internal-7054-ca-org1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/host-docker-internal-7054-ca-org1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/host-docker-internal-7054-ca-org1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/host-docker-internal-7054-ca-org1.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org1.riverchain.com/msp/config.yaml

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@host.docker.internal:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.riverchain.com/peers/peer0.org1.riverchain.com/msp --csr.hosts peer0.org1.riverchain.com --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.riverchain.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.riverchain.com/peers/peer0.org1.riverchain.com/msp/config.yaml

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@host.docker.internal:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.riverchain.com/peers/peer0.org1.riverchain.com/tls --enrollment.profile tls --csr.hosts peer0.org1.riverchain.com --csr.hosts host.docker.internal --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.riverchain.com/peers/peer0.org1.riverchain.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.riverchain.com/peers/peer0.org1.riverchain.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org1.riverchain.com/peers/peer0.org1.riverchain.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org1.riverchain.com/peers/peer0.org1.riverchain.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org1.riverchain.com/peers/peer0.org1.riverchain.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org1.riverchain.com/peers/peer0.org1.riverchain.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.riverchain.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org1.riverchain.com/peers/peer0.org1.riverchain.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.riverchain.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.riverchain.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org1.riverchain.com/peers/peer0.org1.riverchain.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.riverchain.com/tlsca/tlsca.org1.riverchain.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.riverchain.com/ca
  cp ${PWD}/organizations/peerOrganizations/org1.riverchain.com/peers/peer0.org1.riverchain.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org1.riverchain.com/ca/ca.org1.riverchain.com-cert.pem

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@host.docker.internal:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.riverchain.com/users/User1@org1.riverchain.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.riverchain.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.riverchain.com/users/User1@org1.riverchain.com/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org1admin:org1adminpw@host.docker.internal:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.riverchain.com/users/Admin@org1.riverchain.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.riverchain.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.riverchain.com/users/Admin@org1.riverchain.com/msp/config.yaml
}

function createOrg2() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/org2.riverchain.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org2.riverchain.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@host.docker.internal:8054 --caname ca-org2 --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/host-docker-internal-8054-ca-org2.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/host-docker-internal-8054-ca-org2.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/host-docker-internal-8054-ca-org2.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/host-docker-internal-8054-ca-org2.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org2.riverchain.com/msp/config.yaml

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@host.docker.internal:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.riverchain.com/peers/peer0.org2.riverchain.com/msp --csr.hosts peer0.org2.riverchain.com --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.riverchain.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.riverchain.com/peers/peer0.org2.riverchain.com/msp/config.yaml

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@host.docker.internal:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.riverchain.com/peers/peer0.org2.riverchain.com/tls --enrollment.profile tls --csr.hosts peer0.org2.riverchain.com --csr.hosts host.docker.internal --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.riverchain.com/peers/peer0.org2.riverchain.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.riverchain.com/peers/peer0.org2.riverchain.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org2.riverchain.com/peers/peer0.org2.riverchain.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org2.riverchain.com/peers/peer0.org2.riverchain.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org2.riverchain.com/peers/peer0.org2.riverchain.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org2.riverchain.com/peers/peer0.org2.riverchain.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.riverchain.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org2.riverchain.com/peers/peer0.org2.riverchain.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.riverchain.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.riverchain.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org2.riverchain.com/peers/peer0.org2.riverchain.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.riverchain.com/tlsca/tlsca.org2.riverchain.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.riverchain.com/ca
  cp ${PWD}/organizations/peerOrganizations/org2.riverchain.com/peers/peer0.org2.riverchain.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org2.riverchain.com/ca/ca.org2.riverchain.com-cert.pem

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@host.docker.internal:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.riverchain.com/users/User1@org2.riverchain.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.riverchain.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.riverchain.com/users/User1@org2.riverchain.com/msp/config.yaml

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org2admin:org2adminpw@host.docker.internal:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.riverchain.com/users/Admin@org2.riverchain.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.riverchain.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.riverchain.com/users/Admin@org2.riverchain.com/msp/config.yaml
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/riverchain.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/riverchain.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@host.docker.internal:9054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/host-docker-internal-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/host-docker-internal-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/host-docker-internal-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/host-docker-internal-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/riverchain.com/msp/config.yaml

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@host.docker.internal:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/riverchain.com/orderers/orderer.riverchain.com/msp --csr.hosts orderer.riverchain.com --csr.hosts host.docker.internal --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/riverchain.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/riverchain.com/orderers/orderer.riverchain.com/msp/config.yaml

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@host.docker.internal:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/riverchain.com/orderers/orderer.riverchain.com/tls --enrollment.profile tls --csr.hosts orderer.riverchain.com --csr.hosts host.docker.internal --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/riverchain.com/orderers/orderer.riverchain.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/riverchain.com/orderers/orderer.riverchain.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/riverchain.com/orderers/orderer.riverchain.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/riverchain.com/orderers/orderer.riverchain.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/riverchain.com/orderers/orderer.riverchain.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/riverchain.com/orderers/orderer.riverchain.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/riverchain.com/orderers/orderer.riverchain.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/riverchain.com/orderers/orderer.riverchain.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/riverchain.com/orderers/orderer.riverchain.com/msp/tlscacerts/tlsca.riverchain.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/riverchain.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/riverchain.com/orderers/orderer.riverchain.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/riverchain.com/msp/tlscacerts/tlsca.riverchain.com-cert.pem

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@host.docker.internal:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/riverchain.com/users/Admin@riverchain.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/orderer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/riverchain.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/riverchain.com/users/Admin@riverchain.com/msp/config.yaml
}
