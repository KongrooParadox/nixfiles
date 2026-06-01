{
  inputs,
  ...
}:
let
  localModel = "qwen2.5-coder-3b";
in
{
  imports = [
    ../../modules/nixos/asahi
    ./hardware-configuration.nix
    inputs.apple-silicon.nixosModules.default
  ];

  home-manager.users.ops.kp.openclaw = {
    enable = true;
    model = localModel;
    contextWindow = 16384;
    reserveTokens = 8192;
    allowedTools = [
      "read"
      "write"
      "edit"
      "exec"
    ];
  };

  kp = {
    arr = {
      enable = true;
      bazarr.subgen.enable = true;
      computeBasePath = "/var/lib/compute";
      dispatcharr.enable = false;
      mediaBasePath = "/mnt/share/media";
    };
    home-manager.enable = true;
    impermanence.enable = true;
    llm = {
      enable = true;
      llamaCpp = {
        enable = true;
        acceleration = "cpu";
        alias = localModel;
        modelFile = "qwen2.5-coder-3b-instruct-q4_k_m.gguf";
        modelUrl = "https://huggingface.co/Qwen/Qwen2.5-Coder-3B-Instruct-GGUF/resolve/main/qwen2.5-coder-3b-instruct-q4_k_m.gguf";
        contextSize = 16384;
      };
    };
    samba.client = {
      enable = true;
      uid = "1000";
      gid = "997";
    };
    ups.enable = true;
    virtualization = {
      enable = true;
      bridgeInterfaceName = "end0";
      libvirtd.enable = true;
    };
    zfs = {
      enable = true;
      encryptionKeys = [ "encrypted.key" ];
      hostId = "a3c9f91c";
    };
  };
}
