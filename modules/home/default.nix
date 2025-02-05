{ pkgs, ... }:
{
  imports = [
    ./browser.nix
    ./desktop.nix
    ./editor.nix
    ./emoji.nix
    ./git.nix
    ./hyprland.nix
    ./rofi.nix
    ./hyprlock.nix
    ./swaync.nix
    ./terminal.nix
    ./waybar.nix
    ./wlogout.nix
  ];

  home = {
    file = {
      "libvirt.conf" = {
        source = ../../dotfiles/libvirt;
        target = ".config/libvirt";
      };
      ".config/nvim" = {
        source = ../../dotfiles/nvim;
        recursive = true;
      };
      "scripts" = {
        source = ../../dotfiles/bin;
        target = ".local/bin";
      };
      ".ssh/config" = {
        source = ../../dotfiles/ssh/config;
      };
    };

    packages = with pkgs; [
      ansible
      ansible-lint
      cargo
      neofetch
      rustc
      starship
    ];
  };
}
