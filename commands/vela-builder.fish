function vela-builder
    set -e RED;    set RED    (set_color red)
    set -e GREEN;  set GREEN  (set_color green)
    set -e YELLOW; set YELLOW (set_color yellow)
    set -e RESET;  set RESET  (set_color normal)

    set -l container_name "vela-builder-"(basename (pwd))
    set -l ssh_src $HOME/.ssh
    set -l ssh_dst /root/.ssh

    if ! type -q podman
        echo $RED"Podman is not installed"$RESET >&2
        echo $YELLOW"Please install first："$RESET >&2
        echo "  "$GREEN"# Debian/Ubuntu"$RESET >&2
        echo "  sudo apt update && sudo apt install -y podman" >&2
        echo "  "$GREEN"# Fedora/RHEL/CentOS"$RESET >&2
        echo "  sudo dnf install -y podman" >&2
        echo "  "$GREEN"# Arch Linux"$RESET >&2
        echo "  sudo pacman -S --noconfirm podman" >&2
        echo "  paru -S podman" >&2
        return -1
    end


    if test (count $argv) -eq 0
        podman exec -it $container_name bash 2>/dev/null; or \
        podman run -it --rm \
               --name $container_name \
               -v (pwd):(pwd):Z \
               -v $ssh_src:$ssh_dst:Z \
               -w (pwd) \
               ghcr.io/w-mai/vela-builder:latest \
               bash
    else
        set -l cmd (string join " " $argv)
        podman exec -i $container_name bash -c "$cmd" 2>/dev/null; or \
        podman run -i --rm \
               --name $container_name \
               -v (pwd):(pwd):Z \
               -v $ssh_src:$ssh_dst:Z \
               -w (pwd) \
               ghcr.io/w-mai/vela-builder:latest \
               bash -c "$cmd"
    end
end

