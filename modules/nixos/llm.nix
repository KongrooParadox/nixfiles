{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kp.llm;
  lcfg = config.kp.llm.llamaCpp;
  useVulkan = lcfg.acceleration == "vulkan";
  modelPath = "${lcfg.modelsDir}/${lcfg.modelFile}";
in
{
  options.kp.llm = {
    enable = lib.mkEnableOption "LLM coding tools";

    llamaCpp = {
      enable = lib.mkEnableOption "local llama.cpp OpenAI-compatible server";

      acceleration = lib.mkOption {
        type = lib.types.enum [
          "cpu"
          "vulkan"
        ];
        default = "vulkan";
        description = lib.mdDoc ''
          Inference backend. `vulkan` offloads to the Asahi GPU (requires the
          asahi module's GPU userspace); `cpu` runs purely on CPU.
        '';
      };

      modelsDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/llm/models";
        description = lib.mdDoc "Directory holding GGUF models (kept out of the Nix store, persisted under impermanence).";
      };

      modelFile = lib.mkOption {
        type = lib.types.str;
        default = "qwen2.5-coder-14b-instruct-q4_k_m.gguf";
        description = lib.mdDoc "GGUF file name served by llama-server (looked up inside `modelsDir`).";
      };

      modelUrl = lib.mkOption {
        type = lib.types.str;
        default = "https://huggingface.co/Qwen/Qwen2.5-Coder-14B-Instruct-GGUF/resolve/main/qwen2.5-coder-14b-instruct-q4_k_m.gguf";
        description = lib.mdDoc "URL the model is downloaded from on first start if `modelFile` is missing.";
      };

      modelSha256 = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "sha256-...";
        description = lib.mdDoc "Optional sha256 checksum verified after download (skipped when null).";
      };

      alias = lib.mkOption {
        type = lib.types.str;
        default = "qwen2.5-coder-14b";
        description = lib.mdDoc "Model id advertised over the OpenAI-compatible API.";
      };

      contextSize = lib.mkOption {
        type = lib.types.ints.positive;
        default = 8192;
        description = lib.mdDoc ''
          Context window size (`-c`). Larger values need more GPU/CPU memory for
          the KV cache; raise it once you've confirmed the model fits.
        '';
      };

      gpuLayers = lib.mkOption {
        type = lib.types.str;
        default = "auto";
        description = lib.mdDoc "Number of layers to offload to the GPU (`-ngl`, only used with the vulkan backend).";
      };

      flashAttention = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Enable Flash Attention (`-fa on`). Required for KV-cache quantization.";
      };

      kvCacheType = lib.mkOption {
        type = lib.types.enum [
          "f16"
          "q8_0"
          "q4_0"
        ];
        default = "f16";
        example = "q8_0";
        description = lib.mdDoc ''
          KV-cache quantization type (`-ctk`/`-ctv`). Halves (`q8_0`) or quarters
          (`q4_0`) KV memory so a larger context fits in VRAM. Requires
          `flashAttention = true`.
        '';
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = lib.mdDoc "Address llama-server listens on.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = lib.mdDoc "Port llama-server listens on (OpenAI-compatible API under /v1).";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Open the llama-server port in the firewall.";
      };

    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ opencode ];
    services.llama-cpp = lib.mkIf lcfg.enable {
      enable = true;
      package = if useVulkan then pkgs.llama-cpp.override { vulkanSupport = true; } else pkgs.llama-cpp;
      openFirewall = lcfg.openFirewall;
      settings = {
        alias = lcfg.alias;
        ctk = lcfg.kvCacheType;
        ctv = lcfg.kvCacheType;
        ctx-size = lcfg.contextSize;
        flash-attn = if lcfg.flashAttention then "on" else "off";
        host = lcfg.host;
        jinja = true;
        model = modelPath;
        ngl = lcfg.gpuLayers;
        port = lcfg.port;
      };
    };

    # Fetch the GGUF into the persisted models dir on first start (kept out of
    # the Nix store). Idempotent: skips when the file already exists.
    systemd.services.llama-cpp-model-fetch = {
      description = "Fetch llama.cpp model (${lcfg.modelFile})";
      before = [ "llama-cpp.service" ];
      requiredBy = [ "llama-cpp.service" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = [
        pkgs.curl
        pkgs.coreutils
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -euo pipefail
        mkdir -p ${lib.escapeShellArg lcfg.modelsDir}
        if [ ! -f ${lib.escapeShellArg modelPath} ]; then
          echo "Downloading ${lcfg.modelFile} from ${lcfg.modelUrl}"
          tmp="$(mktemp ${lib.escapeShellArg lcfg.modelsDir}/.download.XXXXXX)"
          trap 'rm -f "$tmp"' EXIT
          curl -fL --retry 5 --retry-delay 10 --retry-connrefused \
            -o "$tmp" ${lib.escapeShellArg lcfg.modelUrl}
          ${lib.optionalString (lcfg.modelSha256 != null) ''
            echo "${lcfg.modelSha256}  $tmp" | sha256sum -c -
          ''}
          mv "$tmp" ${lib.escapeShellArg modelPath}
          trap - EXIT
        fi
        chmod 0755 ${lib.escapeShellArg lcfg.modelsDir}
        chmod 0444 ${lib.escapeShellArg modelPath}
      '';
    };

    # The upstream service is heavily sandboxed and runs as a DynamicUser; relax
    # the bits that block GPU (Vulkan) access on the Asahi stack.
    systemd.services.llama-cpp.serviceConfig = lib.mkIf useVulkan {
      SupplementaryGroups = [
        "render"
        "video"
      ];
      DeviceAllow = [
        "char-drm rw"
        "/dev/dri rw"
      ];
      PrivateDevices = lib.mkForce false;
      # GPU drivers / shader JIT need writable+executable memory.
      MemoryDenyWriteExecute = lib.mkForce false;
    };

    kp.impermanence.extraDirectories = lib.mkIf config.kp.impermanence.enable [
      "/var/cache/llama-cpp"
      lcfg.modelsDir
    ];
  };
}
