#!/usr/bin/env bash

HOST=elnuevo-2
FQDN="${HOST}.skynet.local"
FQDN="10.10.111.43"
INIT=false
FORMAT=false
MOUNT=false
INSTALL=true

if $INIT; then
    # Init SSH
    ssh-copy-id root@$FQDN
    sops --decrypt --extract "['zfs-dataset']['elnuevo-2']['encrypted.key']" ~/nixfiles/secrets/secrets.yaml > encrypted.key
    ssh root@$FQDN "mkdir -p /run/secrets/zfs-dataset/${HOST}"
    scp ./*.key root@$FQDN:/run/secrets/zfs-dataset/$HOST
    rm ./*.key
    ssh root@$FQDN 'nix-shell -p git --run "git clone https://github.com/KongrooParadox/nixfiles"'
    if $FORMAT; then
        ssh root@$FQDN "cd nixfiles;git switch develop;nix --experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- --mode destroy hosts/${HOST}/disks.nix"
        ssh root@$FQDN "cd nixfiles;nix --experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- --mode format hosts/${HOST}/disks.nix"
    fi
    if $MOUNT; then
        # Generate SSH key for host
        ssh root@$FQDN 'mkdir -p /mnt/persist/etc/ssh/'
        # ssh root@$FQDN "cd nixfiles;git switch develop;nix --experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- --mode mount hosts/${HOST}/disks.nix"
        ssh root@$FQDN 'ssh-keygen -N "" -t ed25519 -f /mnt/persist/etc/ssh/ssh_host_ed25519_key'
        ssh root@$FQDN 'nix-shell -p ssh-to-age --run "ssh-to-age -i /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub"'
        echo -e "##############################\nPlease do the following steps before running nixos-install :\n - Add age key above to .sops.yaml file\n - run 'sops updatekeys secrets/secrets.yaml\n - Commit the changes and push to nixfiles origin !!"
    fi
fi

if $INSTALL; then
    just build-remote $HOST
    attic push asahi ./result
    ssh root@$FQDN 'nix-shell -p attic-client --run "attic use x86"'
    # Install NixOS
    ssh root@$FQDN 'nix-shell -p nom --run "nixos-install --root /mnt --flake github:KongrooParadox/nixfiles/develop#elnuevo-2 | nom"'
fi
