{
  apple-silicon,
  config,
  # nix-ld,
  ...
}:
let
  localModel = "gemma-4-E4B-it-qat-GGUF";
in
{
  imports = [
    ../../modules/nixos/asahi
    ./hardware-configuration.nix
    apple-silicon.nixosModules.default
    # nix-ld.nixosModules.nix-ld
  ];

  config = {
    home-manager.users.robot.kp = {
      emacs.enable = false;
      pentest.enable = true;
      hyprland.bar = "noctalia";
      openclaw = {
        enable = true;
        model = localModel;
        # Match the llama.cpp server context; shrink the response reserve so the
        # agent's large (~12k incl. tool schemas) prompt leaves usable room.
        contextWindow = 24576;
        reserveTokens = 8192;
        # Minimal tool set: OpenClaw proactively compacts when the prompt nears
        # its (small, default-8k) per-model budget; fewer tools keeps the fixed
        # prompt under that threshold so it doesn't loop on uncompactable context.
        allowedTools = [
          "read"
          "write"
          "edit"
          "exec"
        ];
      };
    };
    kp = {
      desktop.enable = true;
      home-manager.enable = true;
      impermanence.enable = true;
      llm = {
        enable = true;
        llamaCpp = {
          enable = true;
          alias = localModel;
          modelFile = "gemma-4-E4B-it-qat-UD-Q4_K_XL.gguf";
          modelUrl = "https://huggingface.co/unsloth/gemma-4-E4B-it-qat-GGUF/resolve/main/gemma-4-E4B-it-qat-UD-Q4_K_XL.gguf";
          contextSize = 24576;
        };
      };
      networking.networkmanager = {
        enable = true;
        wireless = true;
      };
      podman.enable = true;
      samba.client.enable = true;
      tailscale = {
        autoconnect = true;
        acceptRoutes = true;
      };
      virtualization.enable = true;
      wireguard.enable = true;
      zfs = {
        enable = true;
        hostId = "720320e5";
      };
    };

    # programs.nix-ld.dev.enable = true;

    sops.secrets."wireguard/proton/ar-25" = { };
    networking.wg-quick.interfaces.wg-ar-25 = {
      address = [ "10.2.0.2/32" ];
      autostart = false;
      dns = [
        "10.2.0.1"
      ];
      privateKeyFile = config.sops.secrets."wireguard/proton/ar-25".path;
      peers = [
        {
          publicKey = "0qOv5inT/bLBy2/vjMfwvhWTTN+qA2c/vgKMCqFYd1g=";
          allowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
          endpoint = "103.106.58.163:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
