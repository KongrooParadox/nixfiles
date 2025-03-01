{ inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      inputs.nixos-hardware.nixosModules.dell-inspiron-7405
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.extraEntries."debian.conf" = ''
    title Debian
    efi   /efi/debian/shimx64.efi'';

  desktop = {
    enable = true;
    environment = "plasma";
  };

  virtualization.enable = true;
}
