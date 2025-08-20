architecture := `uname -a | awk '{ print $(NF-1) }'`

build:
    nixos-rebuild build --flake .#

build-iso-arm:
    nix build .#nixosConfigurations.iso-arm.config.system.build.isoImage

build-iso-x86:
    nix build .#nixosConfigurations.iso-x86.config.system.build.isoImage

build-remote HOSTNAME:
    nixos-rebuild build --flake .#{{HOSTNAME}}

boot:
    nixos-rebuild boot --flake .# --sudo

switch:
    nixos-rebuild switch --flake .# --sudo

switch-remote FQDN:
    #!/usr/bin/env bash
    hostname=$(echo {{FQDN}} | awk -F '.' {'print $1'})
    remoteArch=$(ssh {{FQDN}} "uname -a | awk '{ print \$(NF-1) }'" )
    if [[ "{{architecture}}" == "$remoteArch" ]];
        then nixos-rebuild switch --flake .#$hostname --sudo --target-host {{FQDN}}
        else nixos-rebuild switch --flake .#$hostname --sudo --build-host {{FQDN}} --target-host {{FQDN}}
    fi

test:
    nixos-rebuild test --flake .# --sudo
