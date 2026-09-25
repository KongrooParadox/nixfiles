architecture := `uname -a | awk '{ print $(NF-1) }'`

build:
    nixos-rebuild build --flake .# --sudo |& nom

boot:
    nixos-rebuild boot --flake .# --sudo |& nom

build-iso-arm:
    nix build .#nixosConfigurations.iso-arm.config.system.build.isoImage |& nom

build-iso-x86:
    nix build .#nixosConfigurations.iso-x86.config.system.build.isoImage |& nom

build-remote HOSTNAME:
    nixos-rebuild build --flake .#{{HOSTNAME}} |& nom

check:
    nix flake check |& nom

# Build a host's system and report its closure size and 20 biggest store paths
closure HOSTNAME:
    #!/usr/bin/env bash
    set -euo pipefail
    out=$(nix build --no-link --print-out-paths .#nixosConfigurations.{{HOSTNAME}}.config.system.build.toplevel)
    nix path-info -Sh "$out"
    nix path-info -rs "$out" | sort -k2 -n | tail -20 | numfmt --field=2 --to=iec --padding=8

# Closure size of every NixOS host (x86_64 hosts build through binfmt emulation)
sizes:
    #!/usr/bin/env bash
    set -uo pipefail
    for host in $(nix eval --json .#nixosConfigurations --apply builtins.attrNames | jq -r '.[] | select(startswith("iso-") | not)'); do
        if out=$(nix build --no-link --print-out-paths .#nixosConfigurations.$host.config.system.build.toplevel 2>/dev/null); then
            printf '%-12s %s\n' "$host" "$(nix path-info -Sh "$out" | awk '{print $2, $3}')"
        else
            printf '%-12s %s\n' "$host" "build failed"
        fi
    done

# What changed in a host's closure since a jj revision (default: the parent change)
closure-diff HOSTNAME REV="@-":
    #!/usr/bin/env bash
    set -euo pipefail
    attr=nixosConfigurations.{{HOSTNAME}}.config.system.build.toplevel
    rev=$(jj log --no-graph -r '{{REV}}' -T commit_id)
    old=$(nix build --no-link --print-out-paths "git+file://$PWD?rev=$rev#$attr")
    new=$(nix build --no-link --print-out-paths ".#$attr")
    nix store diff-closures "$old" "$new"
    echo "$(nix path-info -Sh "$old" | awk '{print $2, $3}') -> $(nix path-info -Sh "$new" | awk '{print $2, $3}')"

# Whether a host's package is prebuilt on cache.nixos.org, e.g. `just cached njord libreoffice`
cached HOSTNAME PACKAGE:
    #!/usr/bin/env bash
    set -euo pipefail
    out=$(nix eval --raw .#nixosConfigurations.{{HOSTNAME}}.pkgs.{{PACKAGE}}.outPath)
    if nix path-info --store https://cache.nixos.org "$out" >/dev/null 2>&1; then echo "cached: $out"; else echo "not cached: $out"; fi

deploy-remote FQDN COMMAND:
    #!/usr/bin/env bash
    hostname=$(echo {{FQDN}} | awk -F '.' {'print $1'})
    remoteArch=$(ssh {{FQDN}} "uname -a | awk '{ print \$(NF-1) }'" )
    if [[ "{{architecture}}" == "$remoteArch" ]];
        then nixos-rebuild {{COMMAND}} --flake .#$hostname --sudo --target-host {{FQDN}} |& nom
        else nixos-rebuild {{COMMAND}} --flake .#$hostname --sudo --build-host {{FQDN}} --target-host {{FQDN}} |& nom
    fi

repl:
    nixos-rebuild repl --flake .#

switch:
    nixos-rebuild switch --flake .# --sudo |& nom

test:
    nixos-rebuild test --flake .# --sudo |& nom
