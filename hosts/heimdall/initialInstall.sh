#!/usr/bin/env bash

HOST=heimdall
FQDN="${HOST}.skynet.local"
INIT=true
FORMAT=false
MOUNT=true
INSTALL=false

if $INIT; then
    # Init SSH
    ssh-copy-id root@$FQDN
    sops --decrypt --extract "['zfs-dataset']['heimdall']['encrypted.key']" ~/nixfiles/secrets/secrets.yaml > encrypted.key
    ssh root@$FQDN "mkdir -p /run/secrets/zfs-dataset/${HOST}"
    scp ./*.key root@$FQDN:/run/secrets/zfs-dataset/$HOST
    rm ./*.key
    ssh root@$FQDN 'nix-shell -p git --run "git clone https://github.com/KongrooParadox/nixfiles"'
    if $FORMAT; then
        ssh root@$FQDN "cd nixfiles;nix --experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- --mode format hosts/${HOST}/disks.nix"
        # If this fails run the following commands manually :
        # sudo sgdisk --change-name=5:disk-root-zfs --typecode=5:8300 /dev/nvme0n1
        # sudo sgdisk --change-name=7:disk-swap-swap --typecode=7:8200 /dev/nvme0n1
    fi
    if $MOUNT; then
        # Generate SSH key for host
        ssh root@$FQDN 'mkdir -p /mnt/persist/etc/ssh/'
        ssh root@$FQDN "cd nixfiles;nix --experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- --mode mount hosts/${HOST}/disks.nix"
        ssh root@$FQDN 'ssh-keygen -N "" -t ed25519 -f /mnt/persist/etc/ssh/ssh_host_ed25519_key'
        ssh root@$FQDN 'nix-shell -p ssh-to-age --run "ssh-to-age -i /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub"'
        echo -e "##############################\nPlease do the following steps before running nixos-install :\n - Add age key above to .sops.yaml file\n - run 'sops updatekeys secrets/secrets.yaml\n - Commit the changes and push to nixfiles origin !!"
    fi
fi

if $INSTALL; then
    just build-remote $HOST
    attic push asahi ./result
    ssh root@$FQDN 'nix-shell -p attic-client --run "attic use asahi"'
    # Install NixOS
    ssh root@$FQDN 'nixos-install --root /mnt --flake github:KongrooParadox/nixfiles#heimdall'
fi
