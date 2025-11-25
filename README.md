# Vela Builder

Build a virtual compilation environment through `podman` and end the container after the compilation is completed.

1. [Usage](#usage)
2. [Requirement](#requirement)
3. [Installation](#installation)

# Usage

change dir to vela project [openvela](https://github.com/open-vela/)

## Usage 1: Enter environment

exec `vela-builder` command to enter the virtual env

```bash
vela-builder
```

then run any command what you used before in the native environment for building vela.

## Usage 2: Pass the command through to the container

```bash
vela-builder <COMMANDS>
```

example see the `uanme` of the virtual env

```bash
vela-builder "uname -a"
```

you will got like this:

```bash
Linux b643fb8469c9 6.12.41-1-MANJARO #1 SMP PREEMPT_DYNAMIC Fri, 01 Aug 2025 09:46:16 +0000 x86_64 x86_64 x86_64 GNU/Linux
```

# Requirement

podman [installation](https://podman.io/docs/installation)

### Debian
```bash
sudo apt install podman
```

### Arch

#### pacman
```bash
sudo pacman -S podman
```

#### paru
```
paru -S podman
```

### macOS
```
brew install podman
```

# Installation

## Quick install

```bash
curl -fsSL https://raw.githubusercontent.com/W-Mai/vela-builder/main/install.sh | bash
```

### Advanced options

The script accepts:
- `--bash-only` / `--fish-only` – install a single shell wrapper
- `--bash-dir <path>` / `--fish-dir <path>` – override install locations (defaults: `~/.local/bin` and `~/.config/fish/functions`)
- `VELA_BUILDER_RAW=<url>` – custom base URL when hosting your own copy

## Manual install

### bash

```bash
cp commands/vela-builder.sh ~/.local/bin/vela-builder
```

### fish

```bash
cp commands/vela-builder.fish ~/.config/fish/functions
```
