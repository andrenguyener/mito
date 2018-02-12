#!/usr/bin/env bash
echo "building go server for Linux..."
GOOS=linux go build
docker build -t andrenguyener/summary .
go install
go clean