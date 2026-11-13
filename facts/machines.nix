let
  defaults = {
    isLinux = true;
    isSmall = false;
    isUnstable = false;
    site = "oujda";
    users = [ "ops" ];
    usesDisplaylink = false;
  };
in
builtins.mapAttrs (_: machineCfg: defaults // machineCfg) {
  # Darwin
  njord-mac = {
    dhcpReservation = true;
    ipv4 = "192.168.2.53";
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
  elnuevo-1 = {
    dhcpReservation = true;
    aliases = [
      "nextcloud"
      "proxmox"
    ];
    ipv4 = "192.168.2.20";
    stateVersion = "25.05";
  };
  elnuevo-2 = {
    aliases = [ "jellyfin" ];
    dhcpReservation = true;
    ipv4 = "192.168.2.21";
    stateVersion = "25.05";
  };
  frigg = {
    aliases = [ "dns" ];
    ipv4 = "192.168.3.100";
    site = "tavel";
    stateVersion = "26.05";
  };
  iso-arm = {
    stateVersion = "25.05";
  };
  iso-x86 = {
    stateVersion = "25.05";
  };
  lordi = {
    dhcpReservation = true;
    ipv4 = "192.168.2.51";
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
      "dhcp"
      "dns"
      "home-assistant"
    ];
    dhcpReservation = true;
    dhcpServerInterface = "end0";
    ipv4 = "192.168.2.22";
    stateVersion = "25.11";
  };
  yggdrasil = {
    dhcpReservation = true;
    aliases = [
      "dispatcharr"
      "gallery"
      "samba"
    ];
    ipv4 = "192.168.2.23";
    stateVersion = "24.05";
  };

  # NixOS: unstable
  baldur = {
    dhcpReservation = true;
    ipv4 = "192.168.2.50";
    isUnstable = true;
    stateVersion = "23.11";
    users = [
      "fatiha"
      "robot"
    ];
    usesDisplaylink = true;
  };
  heimdall = {
    dhcpReservation = true;
    aliases = [
      "bazarr"
      "deluge"
      "lidarr"
      "nzbget"
      "prowlarr"
      "radarr"
      "sonarr"
    ];
    ipv4 = "192.168.2.24";
    isUnstable = true;
    stateVersion = "24.05";
  };
  njord = {
    dhcpReservation = true;
    ipv4 = "192.168.2.52";
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
  mjolnir = {
    dhcpReservation = true;
    ipv4 = "192.168.2.25";
    isUnstable = true;
    stateVersion = "26.11";
  };
}
