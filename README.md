# Nixfiles

My messy nix config with flakes !

| host | NixOS version | cpu architecture | description |
| --- | --- | --- | --- |
| baldur | 25.05 (unstable) | x86_64 | AMD Laptop |
| njord | 25.05 (unstable) | aarch64 | M2 Macbook Air Laptop |
| heimdall | 25.05 (unstable) | aarch64  | Mac Mini M1 server |
| asgard | 24.11 | aarch64 | DNS for main site (Pi 3) |
| yggdrasil | 24.11 | x86_64 | Main NAS |
| midgard | 24.11 | x86_64 | Backup NAS |
| vili | 24.11 | aarch64 | DNS for secondary site (VM) |

Currently managed configs :
- Laptop workstation = baldur
- M2 Laptop workstation = njord
- Raspberry Pi 3 home-assistant & dns instance = asgard
- NAS running ZFS raidz2 = yggdrasil
- M1 Mac mini hypervisor (libvirt) = heimdall
- NixOS qemu VM templates with cloud-init (only for initial setup)

## Rebuild baldur config

```shell
nixos-rebuild switch --flake .#baldur --use-remote-sudo
```

## Rebuild njord config

```shell
nixos-rebuild switch --flake .#njord --use-remote-sudo
```

## Deploying config to Mac mini

```shell
TARGET="heimdall";NIX_SSHOPTS="-t -T" nixos-rebuild switch --flake .#$TARGET --target-host ops@$TARGET --use-remote-sudo
```

## Deploying config to Raspberry Pi 3

```shell
TARGET="asgard";NIX_SSHOPTS="-t -T" nixos-rebuild switch --flake .#$TARGET --target-host ops@$TARGET --use-remote-sudo
```

## Deploying config to NAS

```shell
TARGET="yggdrasil";NIX_SSHOPTS="-t -T" nixos-rebuild switch --flake .#$TARGET --build-host $TARGET --target-host $TARGET --use-remote-sudoo
```

## Building VM template images

Based on [flake from voidus](https://gist.github.com/voidus/1230b200043b7f815e2513663d16353b)

```shell
nix build ./hosts/vmTemplates/aarch64#image
```

> If building from x86 host this usually takes around 40 minutes.
