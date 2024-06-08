# Nixfiles

My messy nix config with flakes !

Currently managed hosts :
- Laptop workstation
- Raspberry Pi 3 home-assistant instance

## Deploying config to Raspberry Pi 3

```shell
NIX_SSHOPTS="-t" nixos-rebuild switch --flake ./hosts/pi3#rpi --target-host ops@nix-pi301.skynet.local --use-remote-sudo
```
