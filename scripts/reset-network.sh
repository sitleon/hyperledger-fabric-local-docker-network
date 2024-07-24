#!/bin/bash
. scripts/utils.sh

# stop containers (a.k.a local fabric network)
docker-compose down

fabric_vol=$(docker volume ls -q | grep "fabric-loc-network")

if [ ${#fabric_vol} -gt 0 ]; then
    infoln "Remove fabric-loc-network docker volumes"
    docker volume rm $fabric_vol

    infoln "Remove fabric-loc-network data (including ca-cert, sys, channel)"
    rm -Rf .data/**
fi
