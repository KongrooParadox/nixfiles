# Install from scratch (commands run on live session)

## Clone config on target machine

```shell
git clone --branch develop --depth 1 \
  https://github.com/KongrooParadox/nixfiles.git /tmp/nixfiles
```

## Check disk and format using disko 
```shell
readlink -f /dev/disk/by-id/nvme-WD_BLACK_SN850X_HS_2000GB_22400B443101

nix eval --raw \
  'path:/tmp/nixfiles#nixosConfigurations.mjolnir.config.fileSystems."/".fsType'

nix eval \
  'path:/tmp/nixfiles#nixosConfigurations.mjolnir.config.swapDevices' \
  --apply 'map (s: s.device)' --json

nix eval --raw \
  'path:/tmp/nixfiles#nixosConfigurations.mjolnir.config.system.build.toplevel.drvPath'

nix --experimental-features 'nix-command flakes' run \
  github:nix-community/disko/725ea35e410ad83be4931d1bff7e090eacaf3563 -- \
  --mode disko /tmp/nixfiles/hosts/mjolnir/disks.nix
```


## Install system
```shell
findmnt /mnt
lsblk -f /dev/nvme0n1
```

```shell
mkdir -p /mnt/etc/nixos
cp -a /tmp/nixfiles/. /mnt/etc/nixos/
nixos-install --root /mnt --flake '/mnt/etc/nixos#mjolnir'
```

reboot

## After reboot, verify the running system:

nix --experimental-features 'nix-command flakes' run \
  github:nix-community/disko/725ea35e410ad83be4931d1bff7e090eacaf3563 -- \
  --mode mount \
  /tmp/nixfiles/hosts/mjolnir/disks.nix
```shell
findmnt -no SOURCE,FSTYPE /
swapon --show
cat /sys/module/zswap/parameters/enabled
```

