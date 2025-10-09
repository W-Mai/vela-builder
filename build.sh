#!/usr/bin/env bash

TIMESTAMP=$(TZ='Asia/Shanghai' date +%Y%m%d%H%M)
PACKAGE=ghcr.io/w-mai/vela-builder
podman build -t $PACKAGE:$TIMESTAMP .
podman build -t $PACKAGE:latest .

podman push $PACKAGE:$TIMESTAMP
podman push $PACKAGE:latest
