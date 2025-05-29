architecture := `uname -a | awk '{ print $(NF-1) }'`

build:
    nixos-rebuild build --flake .#

boot:
    nixos-rebuild boot --flake .# --use-remote-sudo

switch:
    nixos-rebuild switch --flake .# --use-remote-sudo

switch-remote HOST:
    nixos-rebuild switch --flake .#{{HOST}} --target-host {{HOST}} --use-remote-sudo

switch-remote-build HOST:
    nixos-rebuild switch --flake .#{{HOST}} --build-host {{HOST}}.casa-anita.local --target-host {{HOST}}.casa-anita.local --use-remote-sudo

test:
    nixos-rebuild test --flake .# --use-remote-sudo

var HOST:
    @echo {{architecture}}
    test=$(ssh {{HOST}} "uname -a 2>/dev/null | awk '{ print \$(NF-1) }'" ) ; echo "|$test|";
