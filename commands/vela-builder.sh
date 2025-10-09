#!/usr/bin/env bash
container_name="vela-builder-${PWD##*/}"
ssh_src="$HOME/.ssh"
ssh_dst="/root/.ssh"

if [[ $# -eq 0 ]]; then
    podman exec -it "$container_name" bash 2>/dev/null || \
    podman run -it --rm \
           --name "$container_name" \
           -v "${PWD}:${PWD}:Z" \
           -v "${ssh_src}:${ssh_dst}:Z" \
           -w "${PWD}" \
           ghcr.io/w-mai/vela-builder:latest \
           bash
else
    cmd="$*"
    podman exec -i "$container_name" bash -c "$cmd" 2>/dev/null || \
    podman run -i --rm \
           --name "$container_name" \
           -v "${PWD}:${PWD}:Z" \
           -v "${ssh_src}:${ssh_dst}:Z" \
           -w "${PWD}" \
           ghcr.io/w-mai/vela-builder:latest \
           bash -c "$cmd"
fi

