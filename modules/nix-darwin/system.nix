{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      adwaita-icon-theme
      android-tools
      discord # broken for aarch64
      element-desktop
      gimp # -with-plugins # broken for aarch64
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
      remmina
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
}
