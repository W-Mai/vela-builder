#!/usr/bin/env bash

podman build -t ghcr.io/w-mai/vela-builder:$(TZ='Asia/Shanghai' date +%Y%m%d%H%M) .
