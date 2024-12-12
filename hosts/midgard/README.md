# NAS ZFS install via Disko

## Partition & install

Setup ssh-key:
```shell
ssh-copy-id root@midgard
```

Copy zfs dataset secrets to midgard
```shell
sops --decrypt --extract "['zfs-dataset']['root.key']" secrets/secrets.yaml > root.key
sops --decrypt --extract "['zfs-dataset']['fast.key']" secrets/secrets.yaml > fast.key
sops --decrypt --extract "['zfs-dataset']['rust.key']" secrets/secrets.yaml > rust.key
ssh root@midgard 'mkdir -p /run/secrets/zfs-dataset/'
scp *.key root@midgard:/run/secrets/zfs-dataset/
rm *.key
```

Copy nixconfig from workstation & partition using disko

```shell
scp hosts/midgard/disko.nix root@midgard:/tmp/
# On midgard as root
nix \
  --experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode disko /tmp/disko.nix
```

Install NixOs

```shell
ssh root@midgard 'mkdir -p /mnt/etc/nixos'
scp hosts/midgard/* root@midgard:/mnt/etc/nixos/
scp secrets/secrets.yaml root@midgard:/mnt/etc/nixos/
scp .sops.yaml root@midgard:/mnt/etc/nixos/
ssh root@midgard 'mkdir -p /root/.config/ /mnt/root/.config/'
ssh root@midgard 'sed -e 's#../../secrets#.#' -e 's#~/.config#/root/.config#' /mnt/etc/nixos/flake.nix -i'
scp ~/.config/age.txt root@midgard:/root/.config/
scp ~/.config/age.txt root@midgard:/mnt/root/.config/
# On midgard as root
nixos-install --root /mnt --flake '/mnt/etc/nixos#midgard'
```

Add log mirror to zfs pool

```shell
fdisk /dev/nvme0n1 # d, n, then w
fdisk /dev/nvme1n1 # d, n, then w
zpool add rust log mirror nvme0n1p1 nvme1n1p1
zpool status
```
