#!/usr/bin/env bash

INIT=true
INSTALL=false

if $INIT; then
    # Init SSH
    ssh-copy-id root@yggdrasil
    # Partition drives using disko
    sops --decrypt --extract "['zfs-dataset']['yggdrasil']['root.key']" secrets/secrets.yaml > root.key
    sops --decrypt --extract "['zfs-dataset']['yggdrasil']['fast.key']" secrets/secrets.yaml > fast.key
    sops --decrypt --extract "['zfs-dataset']['yggdrasil']['rust.key']" secrets/secrets.yaml > rust.key
    ssh root@yggdrasil 'mkdir -p /run/secrets/zfs-dataset/'
    scp ./*.key root@yggdrasil:/run/secrets/zfs-dataset/
    rm ./*.key
    scp hosts/yggdrasil/disko.nix root@yggdrasil:/tmp/
    ssh root@yggdrasil 'nix \
      --experimental-features "nix-command flakes" \
      run github:nix-community/disko -- \
      --mode disko /tmp/disko.nix'
    # Generate SSH key for host
    ssh root@yggdrasil 'mkdir -p /mnt/persist/etc/ssh/'
    ssh root@yggdrasil 'ssh-keygen -N "" -t ed25519 -f /mnt/persist/etc/ssh/ssh_host_ed25519_key'
    ssh root@yggdrasil 'nix-shell -p ssh-to-age --run "ssh-to-age -i /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub"'
fi

if $INSTALL; then
    # Install NixOS
    ssh root@yggdrasil 'mkdir -p /mnt/etc/nixos'
    scp hosts/yggdrasil/* root@yggdrasil:/mnt/etc/nixos/
    scp secrets/secrets.yaml root@yggdrasil:/mnt/etc/nixos/
    scp .sops.yaml root@yggdrasil:/mnt/etc/nixos/
    ssh root@yggdrasil 'mkdir -p /root/.config/ /mnt/root/.config/'
    ssh root@yggdrasil 'sed -e 's#../../secrets#.#' -e 's#~/.config#/root/.config#' /mnt/etc/nixos/flake.nix -i'
    ssh root@yggdrasil 'nixos-install --root /mnt --flake '/mnt/etc/nixos#yggdrasil''
fi
