# NAS ZFS install via Disko

## Partition

SSH in :

```shell
lsblk ```

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
scp hosts/yggdrasil/* nixos@yggdrasil:~
ssh ops@yggdrasil
sudo su
mkdir -p /mnt/etc/nixos
mv ./* /mnt/etc/nixos/
cd /mnt/etc/nixos/
nixos-install --root /mnt --flake '/mnt/etc/nixos#yggdrasil'
```

Add log mirror to zfs pool

```shell
sudo fdisk /dev/nvme0n1
sudo fdisk /dev/nvme1n1
zpool add rust log mirror nvme0n1p1 nvme1n1p1
sudo zpool add rust log mirror nvme0n1p1 nvme1n1p1
zpool status
```

## bht : Burn in HDD

### Launch test

```shell
mkdir -p ~/bht-data
git clone https://github.com/ezonakiusagi/bht.git
ksh bht/bht -d ~/bht-data /dev/sd[a-b] /dev/sd[e-h]
```

### Monitor test result
```shell
ksh bht/bht -d ~/bht-data --status
iostat -p /dev/sd[a-b] /dev/sd[e-h] -h;hddtemp /dev/sd[a-b] /dev/sd[e-h] -q -uC
```

### Final output (run 1)
```

[root@yggdrasil:/home/ops]# ksh bht/bht -d ~/bht-data --status
```
