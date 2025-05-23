{ pkgs, ... }:
{
  imports = [
    ./browser.nix
    ./desktop.nix
    ./editor.nix
    ./git.nix
    ./macos.nix
    ./rclone.nix
    ./terminal.nix
  ];

  home = {
    file = {
      "libvirt.conf" = {
        source = ../../dotfiles/libvirt;
        target = ".config/libvirt";
      };
      ".config/k9s" = {
        source = ../../dotfiles/k9s;
        recursive = true;
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
