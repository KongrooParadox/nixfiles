# Nixfiles

My flake that is supports my homelab infra-as-code, and dotfiles.

Despite having played around with Nix for two years in my spare time, this is still very much a work in progress !

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

## Switch to new config for remote host

```shell
just switch-remote FQDN
```

