#!/usr/bin/env bash
chmod +x build.sh
./build.sh
docker push andrenguyener/mitoprototype
chmod +x provision.sh

ssh -oStrictHostKeyChecking=no root@165.227.18.0 'bash -s' < provision.sh