#!/usr/bin/env bash

INIT=true
INSTALL=false

if $INIT; then
    # Init SSH
    ssh-copy-id root@midgard
    # Partition drives using disko
    sops --decrypt --extract "['zfs-dataset']['midgard']['root.key']" secrets/secrets.yaml > root.key
    sops --decrypt --extract "['zfs-dataset']['midgard']['rust.key']" secrets/secrets.yaml > rust.key
    ssh root@midgard 'mkdir -p /run/secrets/zfs-dataset/'
    scp ./*.key root@midgard:/run/secrets/zfs-dataset/
    rm ./*.key
    scp hosts/midgard/disko.nix root@midgard:/tmp/
    ssh root@midgard 'nix \
      --experimental-features "nix-command flakes" \
      run github:nix-community/disko -- \
      --mode disko /tmp/disko.nix'
    # Generate SSH key for host
    ssh root@midgard 'mkdir -p /mnt/persist/etc/ssh/'
    ssh root@midgard 'ssh-keygen -N "" -t ed25519 -f /mnt/persist/etc/ssh/ssh_host_ed25519_key'
    ssh root@midgard 'nix-shell -p ssh-to-age --run "ssh-to-age -i /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub"'
fi

if $INSTALL; then
    # Install NixOS
    ssh root@midgard 'mkdir -p /mnt/etc/nixos'
    scp hosts/midgard/* root@midgard:/mnt/etc/nixos/
    scp secrets/secrets.yaml root@midgard:/mnt/etc/nixos/
    scp .sops.yaml root@midgard:/mnt/etc/nixos/
    ssh root@midgard 'mkdir -p /root/.config/ /mnt/root/.config/'
    ssh root@midgard 'sed -e 's#../../secrets#.#' -e 's#~/.config#/root/.config#' /mnt/etc/nixos/flake.nix -i'
    ssh root@midgard 'nixos-install --root /mnt --flake '/mnt/etc/nixos#midgard''
fi
