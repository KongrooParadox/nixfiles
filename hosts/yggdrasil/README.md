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
# On yggdrasil as root
cd /mnt/etc/nixos/
nixos-generate-config --no-filesystems --root /mnt
nixos-install --root /mnt --flake '/mnt/etc/nixos#yggdrasil'
```

## bht 

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
ST12000NM0127_ZJV3ZE40:
        badblocks[Reading and comparing Pass completed, 0 bad blocks found. (0/0/0 errors)]
        HDD Type:[SATA]
        SMART:[Reallocated_Sector_Ct=64]
        SMART:[Power_On_Hours=216]
        SMART:[Multi_Zone_Error_Rate=0]
ST12000NM0127_ZJV3ZCZA:
        badblocks[Reading and comparing Pass completed, 0 bad blocks found. (0/0/0 errors)]
        HDD Type:[SATA]
        SMART:[Reallocated_Sector_Ct=0]
        SMART:[Power_On_Hours=212]
        SMART:[Multi_Zone_Error_Rate=0]
ST12000NM0127_ZJV3RSWV:
        badblocks[Reading and comparing Pass completed, 0 bad blocks found. (0/0/0 errors)]
        HDD Type:[SATA]
        SMART:[Reallocated_Sector_Ct=0]
        SMART:[Power_On_Hours=142]
        SMART:[Multi_Zone_Error_Rate=0]
ST12000NM0127_ZJV55VXG:
        badblocks[Reading and comparing Pass completed, 0 bad blocks found. (0/0/0 errors)]
        HDD Type:[SATA]
        SMART:[Reallocated_Sector_Ct=0]
        SMART:[Power_On_Hours=166]
        SMART:[Multi_Zone_Error_Rate=0]
ST12000NM0127_ZJV4AA2D:
        badblocks[Reading and comparing Pass completed, 0 bad blocks found. (0/0/0 errors)]
        HDD Type:[SATA]
        SMART:[Reallocated_Sector_Ct=0]
        SMART:[Power_On_Hours=215]
        SMART:[Multi_Zone_Error_Rate=0]
ST12000NM0127_ZJV2PS6W:
        badblocks[Reading and comparing Pass completed, 0 bad blocks found. (0/0/0 errors)]
        HDD Type:[SATA]
        SMART:[Reallocated_Sector_Ct=0]
        SMART:[Power_On_Hours=216]
        SMART:[Multi_Zone_Error_Rate=0]
```
