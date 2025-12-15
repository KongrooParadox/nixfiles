architecture := `uname -a | awk '{ print $(NF-1) }'`

build:
    nixos-rebuild build --flake .# |& nom

build-iso-arm:
    nix build .#nixosConfigurations.iso-arm.config.system.build.isoImage |& nom

build-iso-x86:
    nix build .#nixosConfigurations.iso-x86.config.system.build.isoImage |& nom

build-remote HOSTNAME:
    nixos-rebuild build --flake .#{{HOSTNAME}} |& nom

boot:
    nixos-rebuild boot --flake .# --sudo |& nom

switch:
    nixos-rebuild switch --flake .# --sudo |& nom

switch-remote FQDN:
    #!/usr/bin/env bash
    hostname=$(echo {{FQDN}} | awk -F '.' {'print $1'})
    remoteArch=$(ssh {{FQDN}} "uname -a | awk '{ print \$(NF-1) }'" )
    if [[ "{{architecture}}" == "$remoteArch" ]];
        then nixos-rebuild switch --flake .#$hostname --sudo --target-host {{FQDN}} |& nom
        else nixos-rebuild switch --flake .#$hostname --sudo --build-host {{FQDN}} --target-host {{FQDN}} |& nom
    fi

test:
    nixos-rebuild test --flake .# --sudo |& nom
