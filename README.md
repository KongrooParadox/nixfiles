# Nixfiles

My messy nix config with flakes !

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
nixos-rebuild switch --flake ./hosts/njord#njord --use-remote-sudo
```

## Deploying config to Mac mini

```shell
TARGET="heimdall";NIX_SSHOPTS="-t" nixos-rebuild switch --flake ./hosts/$TARGET#$TARGET --target-host ops@$TARGET --use-remote-sudo
```

## Deploying config to Raspberry Pi 3

```shell
TARGET="asgard";NIX_SSHOPTS="-t" nixos-rebuild switch --flake ./hosts/$TARGET#$TARGET --target-host ops@$TARGET --use-remote-sudo
```

## Deploying config to NAS

```shell
TARGET="yggdrasil";NIX_SSHOPTS="-t -T" nixos-rebuild switch --flake ./hosts/$TARGET#$TARGET --build-host ops@$TARGET --target-host ops@$TARGET --use-remote-sudoo
```

## Building VM template images

Based on [flake from voidus](https://gist.github.com/voidus/1230b200043b7f815e2513663d16353b)

```shell
nix build ./hosts/vmTemplates/aarch64#image
```

> If building from x86 host this usually takes around 40 minutes.
