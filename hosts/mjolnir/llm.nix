{
  config,
  domain,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.mjolnir.role == "llm") {
    # The bc250-mesa package provides the RADV Vulkan ICD; enable the graphics
    # driver link so llama.cpp can find it under /run/opengl-driver.
    hardware = {
      graphics.enable = true;
      bc250.features.vramDynamicSplit = 16384; # 16 GiB TTM limit for larger KV caches
    };

    # The community Vulkan setup raises the GTT window; keep it in sync with
    # vramDynamicSplit above.
    boot.kernelParams = [ "amdgpu.gttsize=14750" ];

    environment.systemPackages = [ pkgs.vulkan-tools ];

    kp.llm = {
      enable = true;
      llamaCpp = {
        enable = true;
        acceleration = "vulkan";
        alias = "qwen2.5-coder-7b-instruct";
        modelFile = "qwen2.5-coder-7b-instruct-q4_k_m.gguf";
        modelUrl = "https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/qwen2.5-coder-7b-instruct-q4_k_m.gguf";
        contextSize = 8192;
        gpuLayers = "999";
        flashAttention = true;
        kvCacheType = "q8_0";
        host = "127.0.0.1";
        port = 8080;
        openFirewall = false;
      };
    };

    kp.reverseProxy = {
      enable = true;
      domain = domain;
      services.llm = {
        port = 8080;
        subdomain = "llm";
      };
    };
  };
}
