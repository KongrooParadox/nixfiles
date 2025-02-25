# NAS ZFS install via Disko

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

## Partition & install

Setup ssh-key:
```shell
ssh-copy-id root@yggdrasil.skynet.local
```

Copy zfs dataset secrets to yggdrasil
```shell
sops --decrypt --extract "['zfs-dataset']['yggdrasil']['root.key']" secrets/secrets.yaml > root.key
sops --decrypt --extract "['zfs-dataset']['yggdrasil']['fast.key']" secrets/secrets.yaml > fast.key
sops --decrypt --extract "['zfs-dataset']['yggdrasil']['rust.key']" secrets/secrets.yaml > rust.key
ssh root@yggdrasil.skynet.local 'mkdir -p /run/secrets/zfs-dataset/'
scp *.key root@yggdrasil.skynet.local:/run/secrets/zfs-dataset/
rm *.key
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

Copy nixconfig from workstation & partition using disko

```shell
scp hosts/yggdrasil/disks.nix root@yggdrasil.skynet.local:/tmp/
# On yggdrasil as root
nix \
  --experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode disko /tmp/disks.nix
```

Install NixOs

```shell
ssh root@yggdrasil.skynet.local 'mkdir -p /mnt/etc/nixos'
scp -R . root@yggdrasil.skynet.local:/mnt/etc/nixos/
scp secrets/secrets.yaml root@yggdrasil.skynet.local:/mnt/etc/nixos/
scp .sops.yaml root@yggdrasil.skynet.local:/mnt/etc/nixos/
ssh root@yggdrasil.skynet.local 'mkdir -p /root/.config/ /mnt/root/.config/'
ssh root@yggdrasil.skynet.local 'sed -e 's#../../secrets#.#' -e 's#~/.config#/root/.config#' /mnt/etc/nixos/flake.nix -i'
scp ~/.config/age.txt root@yggdrasil.skynet.local:/root/.config/
scp ~/.config/age.txt root@yggdrasil.skynet.local:/mnt/root/.config/
# On yggdrasil as root
nixos-install --root /mnt --flake '/mnt/etc/nixos#yggdrasil'
```

Add log mirror to zfs pool

```shell
fdisk /dev/nvme0n1 # d, n, then w
fdisk /dev/nvme1n1 # d, n, then w
zpool add rust log mirror nvme0n1p1 nvme1n1p1
zpool status
```
