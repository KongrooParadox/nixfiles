{
  apple-silicon,
  config,
  # nix-ld,
  ...
}:
{
  imports = [
    ../../modules/nixos/asahi
    ./hardware-configuration.nix
    apple-silicon.nixosModules.default
    # nix-ld.nixosModules.nix-ld
  ];

  config = {
    home-manager.users.robot.kp.pentest.enable = true;
    kp = {
      desktop.enable = true;
      home-manager.enable = true;
      impermanence.enable = true;
      podman.enable = true;
      samba.client.enable = true;
      tailscale.acceptRoutes = true;
      virtualization.enable = true;
      wireguard.enable = true;
      zfs = {
        enable = true;
        hostId = "720320e5";
      };
    };

    nixpkgs.overlays = [
      apple-silicon.overlays.apple-silicon-overlay
    ];

    # programs.nix-ld.dev.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    sops.secrets."wireguard/proton/ar-25" = { };
    networking.wg-quick.interfaces.wg-ar-25 = {
      address = [ "10.2.0.2/32" ];
      autostart = false;
      dns = [
        "192.168.2.100"
        "192.168.1.100"
      ];
      privateKeyFile = config.sops.secrets."wireguard/proton/ar-25".path;
      peers = [
        {
          publicKey = "pPR96SBtq9grARK6XDm5WI3XP1d8Le19Jl/HA9p7o00=";
          allowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
          endpoint = "149.102.224.161:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
