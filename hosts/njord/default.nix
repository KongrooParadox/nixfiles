{
  apple-silicon,
  config,
  # nix-ld,
  ...
}:
let
  localModel = "qwen2.5-coder-7b";
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
          modelFile = "qwen2.5-coder-7b-instruct-q4_k_m.gguf";
          modelUrl = "https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/qwen2.5-coder-7b-instruct-q4_k_m.gguf";
          contextSize = 24576;
        };
      };
      networking.networkmanager = {
        enable = true;
        wireless = true;
      };
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

    # programs.nix-ld.dev.enable = true;

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
