architecture := `uname -a | awk '{ print $(NF-1) }'`

build:
    nixos-rebuild build --flake .#

build-remote HOSTNAME:
    nixos-rebuild build --flake .#{{HOSTNAME}}

boot:
    nixos-rebuild boot --flake .# --use-remote-sudo

switch:
    nixos-rebuild switch --flake .# --use-remote-sudo

switch-remote FQDN:
    #!/usr/bin/env bash
    hostname=$(echo {{FQDN}} | awk -F '.' {'print $1'})
    remoteArch=$(ssh {{FQDN}} "uname -a | awk '{ print \$(NF-1) }'" )
    if [[ "{{architecture}}" == "$remoteArch" ]];
        then NIX_SSHOPTS="-t -T" nixos-rebuild switch --flake .#$hostname --target-host {{FQDN}} --use-remote-sudo
        else NIX_SSHOPTS="-t -T" nixos-rebuild switch --flake .#$hostname --build-host {{FQDN}} --target-host {{FQDN}} --use-remote-sudo
    fi

test:
    nixos-rebuild test --flake .# --use-remote-sudo
