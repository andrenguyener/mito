#!/usr/bin/env bash
echo "building go server for Linux..."
GOOS=linux go build
docker build -t andrenguyener/gatewaymito .
go install
go clean