let
  defaults = {
    isLinux = true;
    isSmall = false;
    isUnstable = false;
    site = "tavel";
    users = [ "ops" ];
    usesDisplaylink = false;
  };
in
builtins.mapAttrs (_: machineCfg: defaults // machineCfg) {
  # Darwin
  njord-mac = {
    isLinux = false;
    isUnstable = true;
    stateVersion = "25.05";
    users = [ "robot" ];
  };
  # NixOS: stable
  asgard = {
    aliases = [
      "dns"
      "home-assistant"
    ];
    ipv4 = "192.168.1.100";
    site = "pernes";
    stateVersion = "24.05";
  };
  box = {
    ipv4 = "192.168.3.100";
    site = "avignon";
    stateVersion = "26.05";
    isSmall = true;
  };
  elnuevo-1 = {
    aliases = [
      "nextcloud"
      "proxmox"
    ];
    ipv4 = "192.168.2.99";
    stateVersion = "25.05";
  };
  elnuevo-2 = {
    aliases = [ "jellyfin" ];
    ipv4 = "192.168.2.100";
    stateVersion = "25.05";
  };
  iso-arm = {
    stateVersion = "25.05";
  };
  iso-x86 = {
    stateVersion = "25.05";
  };
  lordi = {
    users = [
      "fatiha"
      "robot"
    ];
    stateVersion = "25.05";
    usesDisplaylink = true;
  };
  midgard = {
    aliases = [
      "deluge"
      "dispatcharr"
      "gallery"
      "jellyfin"
      "lidarr"
      "nzbget"
      "prowlarr"
      "radarr"
      "samba"
      "sonarr"
    ];
    ipv4 = "192.168.1.101";
    site = "pernes";
    stateVersion = "24.11";
  };
  vili = {
    aliases = [
      "dns"
      "home-assistant"
    ];
    ipv4 = "192.168.2.103";
    stateVersion = "25.11";
  };
  yggdrasil = {
    aliases = [
      "dispatcharr"
      "gallery"
      "samba"
    ];
    ipv4 = "192.168.2.101";
    stateVersion = "24.05";
  };

  # NixOS: unstable
  baldur = {
    isUnstable = true;
    stateVersion = "23.11";
    users = [
      "fatiha"
      "robot"
    ];
    usesDisplaylink = true;
  };
  heimdall = {
    aliases = [
      "bazarr"
      "deluge"
      "lidarr"
      "nzbget"
      "prowlarr"
      "radarr"
      "sonarr"
    ];
    ipv4 = "192.168.2.102";
    isUnstable = true;
    stateVersion = "24.05";
  };
  njord = {
    isUnstable = true;
    stateVersion = "24.11";
    users = [ "robot" ];
    usesDisplaylink = true;
  };
  oci-arm = {
    aliases = [
      "vpn"
    ];
    ipv4 = "10.0.1.211";
    isSmall = true;
    isUnstable = true;
    site = "mrs";
    stateVersion = "26.11";
  };
}
