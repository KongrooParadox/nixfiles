# Nixfiles

My messy nix config with flakes !

Currently managed configs :
- Laptop workstation = baldur
- Raspberry Pi 3 home-assistant instance = asgard
- NixOS qemu VM templates with cloud-init (only for initial setup)

## Deploying config to Raspberry Pi 3

```shell
NIX_SSHOPTS="-t" nixos-rebuild switch --flake ./hosts/asgard#asgard --target-host ops@asgard.skynet.local --use-remote-sudo --impure
```

## Building VM template images

Based on [flake from voidus](https://gist.github.com/voidus/1230b200043b7f815e2513663d16353b)

```shell
nix build ./hosts/vmTemplates/aarch64#image
```

> If building from x86 host this usually takes around 40 minutes.
