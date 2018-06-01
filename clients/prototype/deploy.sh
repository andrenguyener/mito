#!/usr/bin/env bash
chmod +x build.sh
./build.sh
docker push andrenguyener/mitoprototype
chmod +x provision.sh

ssh -oStrictHostKeyChecking=no root@projectmito.io 'bash -s' < provision.sh