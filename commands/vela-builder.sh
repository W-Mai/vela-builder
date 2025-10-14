#!/usr/bin/env bash
container_name="vela-builder-${PWD##*/}"
ssh_src="$HOME/.ssh"
ssh_dst="/root/.ssh"

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

if ! command -v podman >/dev/null 2>&1; then
    echo "${RED}Podman is not installed${RESET}" >&2
    echo "${YELLOW}Please install first：${RESET}" >&2
    echo "  ${GREEN}# Debian/Ubuntu${RESET}" >&2
    echo "  sudo apt update && sudo apt install -y podman" >&2
    echo "  ${GREEN}# Fedora/RHEL/CentOS${RESET}" >&2
    echo "  sudo dnf install -y podman" >&2
    echo "  ${GREEN}# Arch Linux${RESET}" >&2
    echo "  sudo pacman -S --noconfirm podman" >&2
    echo "  paru -S podman" >&2
    exit 1
fi

if [[ $# -eq 0 ]]; then
    podman exec -it "$container_name" bash 2>/dev/null || \
    podman run -it --rm \
           --name "$container_name" \
           --cap-add=SYS_PTRACE \
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
           --cap-add=SYS_PTRACE \
           -v "${PWD}:${PWD}:Z" \
           -v "${ssh_src}:${ssh_dst}:Z" \
           -w "${PWD}" \
           ghcr.io/w-mai/vela-builder:latest \
           bash -c "$cmd"
fi

