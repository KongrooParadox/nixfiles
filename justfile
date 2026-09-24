architecture := `uname -a | awk '{ print $(NF-1) }'`

build:
    nixos-rebuild build --flake .# --sudo |& nom

build-iso-arm:
    nix build .#nixosConfigurations.iso-arm.config.system.build.isoImage |& nom

build-iso-x86:
    nix build .#nixosConfigurations.iso-x86.config.system.build.isoImage |& nom

build-remote HOSTNAME:
    nixos-rebuild build --flake .#{{HOSTNAME}} |& nom

boot:
    nixos-rebuild boot --flake .# --sudo |& nom

check:
    nix flake check |& nom

# Build a host's system and report its closure size and 20 biggest store paths
closure HOSTNAME:
    #!/usr/bin/env bash
    set -euo pipefail
    out=$(nix build --no-link --print-out-paths .#nixosConfigurations.{{HOSTNAME}}.config.system.build.toplevel)
    nix path-info -Sh "$out"
    nix path-info -rs "$out" | sort -k2 -n | tail -20 | numfmt --field=2 --to=iec --padding=8

switch:
    nixos-rebuild switch --flake .# --sudo |& nom

deploy-remote FQDN COMMAND:
    #!/usr/bin/env bash
    hostname=$(echo {{FQDN}} | awk -F '.' {'print $1'})
    remoteArch=$(ssh {{FQDN}} "uname -a | awk '{ print \$(NF-1) }'" )
    if [[ "{{architecture}}" == "$remoteArch" ]];
        then nixos-rebuild {{COMMAND}} --flake .#$hostname --sudo --target-host {{FQDN}} |& nom
        else nixos-rebuild {{COMMAND}} --flake .#$hostname --sudo --build-host {{FQDN}} --target-host {{FQDN}} |& nom
    fi

test:
    nixos-rebuild test --flake .# --sudo |& nom
