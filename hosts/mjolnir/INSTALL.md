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

## Roles: gaming vs LLM

`mjolnir` builds two systemd-boot entries from one generation:

- `NixOS` — gaming (default; Hyprland, Steam/Jovian, Sunshine)
- `NixOS (mjolnir-llm)` — headless llama.cpp server (Vulkan, nginx + DNS)

Pick the entry in the systemd-boot menu, or switch from SSH:

```shell
sudo mjolnir-role status   # gaming | llm
sudo mjolnir-role llm      # set the next boot to mjolnir-llm and reboot
sudo mjolnir-role gaming   # set the next boot back to the gaming generation
```

The LLM role serves the OpenAI-compatible API at `http://127.0.0.1:8080/v1`
and is published as `https://llm.oujda.kongroo.ovh/v1`. Verify after boot:

```shell
systemctl status llama-cpp nginx
curl -s http://127.0.0.1:8080/v1/models
curl -s https://llm.oujda.kongroo.ovh/v1/models
vulkaninfo --summary
```

The model is downloaded on first start into `/var/lib/llm/models` (not the
Nix store). `kp.llm.llamaCpp.acceleration` is `vulkan`; the `rocm` value is an
experimental seam that requires the community `bc250-rocm` patches for gfx1013.

Rebuild both roles from one parent generation:

```shell
just mjolnir-llm   # build the parent + specialisation, mark mjolnir-llm next boot
```

From the gaming role, `just switch` / `just boot` also rebuild the
specialisation. Do not run `just switch` while booted into `mjolnir-llm`: the
default flake attribute is the gaming role, so it would activate the desktop on
the headless system.
