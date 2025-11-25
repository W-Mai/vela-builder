#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${0}}")" && pwd)"
BASH_REL="commands/vela-builder.sh"
FISH_REL="commands/vela-builder.fish"
RAW_BASE="${VELA_BUILDER_RAW:-https://raw.githubusercontent.com/W-Mai/vela-builder/main}"

DEFAULT_BASH_DIR="${HOME}/.local/bin"
DEFAULT_FISH_DIR="${HOME}/.config/fish/functions"

BASH_DIR="${DEFAULT_BASH_DIR}"
FISH_DIR="${DEFAULT_FISH_DIR}"
INSTALL_BASH=1
INSTALL_FISH=1

TMP_FILES=()
cleanup() {
    if [[ ${#TMP_FILES[@]} -eq 0 ]]; then
        return 0
    fi

    for f in "${TMP_FILES[@]}"; do
        if [[ -n "$f" && -f "$f" ]]; then
            rm -f "$f" || true
        fi
    done
}
trap cleanup EXIT

usage() {
    cat <<'EOF'
Install vela-builder helper scripts.

Usage: ./install.sh [options]

Options:
  --bash-only           Install only the bash script
  --fish-only           Install only the fish function
  --bash-dir <path>     Target directory for the bash script (default: ~/.local/bin)
  --fish-dir <path>     Target directory for the fish function (default: ~/.config/fish/functions)
  -h, --help            Show this help message and exit
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --bash-only)
            INSTALL_FISH=0
            ;;
        --fish-only)
            INSTALL_BASH=0
            ;;
        --bash-dir)
            shift || { echo "Missing value for --bash-dir" >&2; exit 1; }
            BASH_DIR="$1"
            ;;
        --fish-dir)
            shift || { echo "Missing value for --fish-dir" >&2; exit 1; }
            FISH_DIR="$1"
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
    shift
done

if [[ ${INSTALL_BASH} -eq 0 && ${INSTALL_FISH} -eq 0 ]]; then
    echo "Nothing to install. Use --bash-only or --fish-only to choose a target." >&2
    exit 1
fi

if ! command -v install >/dev/null 2>&1; then
    echo "'install' command not found. Please install coreutils." >&2
    exit 1
fi

fetch_or_use_local() {
    local rel_path="$1" tmp_file
    if [[ -f "${SCRIPT_DIR}/${rel_path}" ]]; then
        printf '%s' "${SCRIPT_DIR}/${rel_path}"
        return 0
    fi

    if command -v curl >/dev/null 2>&1; then
        tmp_file=$(mktemp)
        TMP_FILES+=("${tmp_file}")
        if ! curl -fsSL "${RAW_BASE}/${rel_path}" -o "${tmp_file}"; then
            echo "Failed to download ${rel_path} from ${RAW_BASE}" >&2
            return 1
        fi
        printf '%s' "${tmp_file}"
        return 0
    fi

    echo "Missing ${rel_path} locally and 'curl' unavailable for download." >&2
    return 1
}

if [[ ${INSTALL_BASH} -eq 1 ]]; then
    BASH_SRC=$(fetch_or_use_local "${BASH_REL}") || exit 1
    install -Dm755 "${BASH_SRC}" "${BASH_DIR}/vela-builder"
    echo "Installed bash wrapper to ${BASH_DIR}/vela-builder"
fi

if [[ ${INSTALL_FISH} -eq 1 ]]; then
    FISH_SRC=$(fetch_or_use_local "${FISH_REL}") || exit 1
    install -Dm644 "${FISH_SRC}" "${FISH_DIR}/vela-builder.fish"
    echo "Installed fish function to ${FISH_DIR}/vela-builder.fish"
fi

cat <<EOF
Installation complete.
- Ensure ${BASH_DIR} is in your PATH to use 'vela-builder'.
- Fish automatically loads functions from ${FISH_DIR}. Run 'functions -c vela-builder' to confirm.
EOF

exit 0
