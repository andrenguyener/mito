#!/usr/bin/env bash
echo "building go server for Linux..."
docker image prune -f
docker build -t andrenguyener/mitonode .
