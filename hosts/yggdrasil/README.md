# NAS ZFS install via Disko

## Partition

SSH in :

```shell
lsblk
```

Create /tmp/disko.nix with correct devices (watch out for disk id changes)

```shell
# On yggdrasil as root
nix \
  --experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode disko /tmp/disko.nix
```

How to mount zfs partitions manually (if not done automagically by disko)

```shell
# On yggdrasil as root
mount -t zfs -o zfsutil zroot/local/{persist,nix,home} /mnt/{persist,nix,home}
mount -t zfs -o zfsutil zroot/local/root /mnt/
# Adapt following device names with boot devices
mount /dev/sdc1 /mnt/boot
mount /dev/sdd1 /mnt/boot-fallback
```

Copy nixconfig from workstation

```shell
ssh root@yggdrasil 'mkdir -p /mnt/etc/nixos'
scp hosts/yggdrasil/* root@yggdrasil:/mnt/etc/nixos/
```

Install NixOs

```shell
# On yggdrasil as root
cd /mnt/etc/nixos/
nixos-generate-config --no-filesystems --root /mnt
nixos-install --root /mnt --flake '/mnt/etc/nixos#yggdrasil'
```

## History
```shell

```
