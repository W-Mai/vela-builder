function vela-builder
    set -l container_name "vela-builder-"(basename (pwd))
    set -l ssh_src $HOME/.ssh
    set -l ssh_dst /root/.ssh

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

