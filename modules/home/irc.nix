{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kp.irc;
in
{
  options.kp.irc = {
    enable = lib.mkEnableOption "irc client & persistent bouncer";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.weechat
    ];
    # services.nginx.virtualHosts."irc-cadey.chrysalis.cetacean.club" = {
    #   # Mara\ "gently encourage" clients to use HTTPS
    #   forceSSL = true;
    #
    #   # Mara\ Proxy everything at `/weechat` to WeeChat
    #   locations."^~ /weechat" = {
    #     # Mara\ Replace the host and port with whatever you configured
    #     # instead of this.
    #     proxyPass = "http://127.0.0.1:9001";
    #     # Mara\ WeeChat has websocket support for the relay protocol,
    #     # this tells nginx to expect that.
    #     proxyWebsockets = true;
    #   };
    #
    #   # Mara\ Serve glowing bear's assets at the root of the domain.
    #   locations."/".root = pkgs.glowing-bear;
    #
    #   # Mara\ Use the ACME cert for `cetacean.club` for this
    #   useACMEHost = "cetacean.club";
    # };
  };
}
