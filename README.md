# Nixfiles

My messy nix config with flakes !

Currently managed configs :
- Laptop workstation
- Raspberry Pi 3 home-assistant instance
- NixOS qemu VM templates with cloud-init (only for initial setup)

## Deploying config to Raspberry Pi 3

```shell
NIX_SSHOPTS="-t" nixos-rebuild switch --flake ./hosts/pi3#rpi --target-host ops@nix-pi301.skynet.local --use-remote-sudo
```

## Building VM template images

Based on [flake from voidus](https://gist.github.com/voidus/1230b200043b7f815e2513663d16353b)

```shell
nix build ./hosts/vmTemplates/aarch64#image
```

> If building from x86 host this usually takes around 40 minutes.
