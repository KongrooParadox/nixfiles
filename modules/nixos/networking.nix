{ host, users, ... }:
{
  networking = {
    firewall = {
      enable = true;
      trustedInterfaces = [
        "wlan0"
        "wlp1s0f0"
        "virbr1"
      ];
    };
    networkmanager.enable = true;
    hostName = host;
  };

  users.users = builtins.listToAttrs (
    map (user: {
      name = user;
      value.extraGroups = [ "networkmanager" ];
    }) users
  );
}
