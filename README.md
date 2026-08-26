# Nixfiles

My flake that is supports my homelab infra-as-code, and dotfiles.

Despite having played around with Nix for a few years in my spare time, this is still very much a work in progress !

## Build config for current host

```shell
just build
```

## Switch to new config for current host

```shell
just switch
```

## Build config for remote host

```shell
just build-remote HOSTNAME
```

## Deploy new config for remote host

```shell
just deploy-remote FQDN COMMAND
```

## Build iso live environment

```shell
# x86
nix build .#nixosConfigurations.iso-x86.config.system.build.isoImage |& nom
# arm
nix build .#nixosConfigurations.iso-arm.config.system.build.isoImage |& nom
```

