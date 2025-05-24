# Nixfiles

My playground to experiment on my machines using Nix flakes.

Having only played around with Nix for around a year, this is very much a work in progress !

| Host | NixOS version | Cpu architecture | Description |
| --- | --- | --- | --- |
| baldur | Unstable | x86_64 | AMD Laptop |
| njord | Unstable | aarch64 | M2 Macbook Air Laptop |
| heimdall | Unstable | aarch64  | Mac Mini M1 server |
| asgard | 25.05 | aarch64 | DNS for main site (Pi 3) |
| yggdrasil | 25.05 | x86_64 | Main NAS |
| midgard | 25.05 | x86_64 | Backup NAS |
| vili | 25.05 | aarch64 | DNS for secondary site (VM) |
| vmTemplates | 25.05 | aarch64 | VM template using cloud-init |

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
