{
  lib,
  pkgs,
  users,
  ...
}:
{
  environment = {
    systemPackages = with pkgs; [
      adwaita-icon-theme
      android-tools
      discord
      element-desktop
      gimp
      gnupg
      go
      helmfile
      hugo
      inkscape
      kubectl
      kubectx
      kubernetes-helm
      k9s
      moonlight-qt
      nixos-anywhere
      nodejs_22
      protonmail-bridge
      python3
      # remmina
      talosctl
      age
      bat
      btop
      cmake
      curl
      direnv
      dnsutils
      fd
      fzf
      gcc
      gnumake
      ipcalc
      jq
      lftp
      nettools
      nix-output-monitor
      nmap
      openssl
      ripgrep
      rsync
      sops
      ssh-to-age
      tcpdump
      tree
      unzip
      virtualenv
      wget
      yq
    ];
  };
  security.pam.services.sudo_local.touchIdAuth = true;
  system = {
    defaults = {
      controlcenter = {
        BatteryShowPercentage = true;
        Bluetooth = true;
        NowPlaying = true;
        Sound = true;
      };
      dock = {
        persistent-apps =
          (lib.lists.concatMap (user: [
            { app = "/Users/${user}/Applications/Home Manager Apps/Alacritty.app"; }
            { app = "/Users/${user}/Applications/Home Manager Apps/Firefox.app"; }
          ]) users)
          ++ [
            { app = "/Applications/Nix Apps/Element.app"; }
            { app = "/Applications/Spotify.app"; }
            { app = "/Applications/Adobe Illustrator 2025/Adobe Illustrator.app"; }
            { app = "/Applications/Nix Apps/GNU Image Manipulation Program.app"; }
            { app = "/Applications/Nix Apps/Inkscape.app"; }
            { app = "/Applications/GeForceNOW.app"; }
            { app = "/Applications/Steam.app"; }
            { app = "/Applications/Nix Apps/Moonlight.app"; }
            # { app = "/Applications/Nix Apps/Remmina.app"; }
            { app = "/System/Applications/System Settings.app"; }
          ];
        persistent-others = lib.lists.concatMap (user: [
          "/Users/${user}/Documents"
          "/Users/${user}/Downloads"
        ]) users;
        show-recents = false;
      };
      finder = {
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        QuitMenuItem = true;
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
      nonUS.remapTilde = true;
    };
    primaryUser = lib.lists.head users;
  };
}
