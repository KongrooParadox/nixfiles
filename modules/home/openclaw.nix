{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.kp.openclaw;
  oc = inputs.nix-openclaw;
  system = pkgs.stdenv.hostPlatform.system;

  sourceInfo = import "${oc}/nix/sources/openclaw-source.nix";

  # nix-openclaw only pins a pnpmDepsHash for x86_64-linux / darwin. The pnpm
  # fetch is deterministic but architecture-specific, so we pin the aarch64-linux
  # hash here. Update this map whenever the upstream OpenClaw release bumps (the
  # assertion below fails loudly when the pin is missing for a new version).
  pnpmDepsHashAarch64 = {
    "2026.5.28" = "sha256-SNXhGNIx2q94gDrHQ3oCdsg+zle0Jh9fQ5ugorE8OXI=";
  };
  ocVersion = sourceInfo.releaseVersion;
  aarch64Hash = pnpmDepsHashAarch64.${ocVersion} or null;
  needsHashPin = system == "aarch64-linux";

  patchedSourceInfo =
    sourceInfo
    // lib.optionalAttrs (needsHashPin && aarch64Hash != null) { pnpmDepsHash = aarch64Hash; };
  ocToolPkgs = oc.inputs.nix-openclaw-tools.packages.${system} or { };

  # Mirror nix-openclaw's overlay package set, but with the patched (aarch64)
  # sourceInfo. We reconstruct `openclawPackages` (incl. `withTools`) because the
  # HM module rebuilds the bundle without the `git` tool when programs.git is on.
  ocImport =
    args:
    import "${oc}/nix/packages" (
      {
        inherit pkgs;
        sourceInfo = patchedSourceInfo;
        openclawToolPkgs = ocToolPkgs;
        qmdPackage = null;
      }
      // args
    );
  openclawPackages = ocImport { } // {
    toolNames =
      (import "${oc}/nix/tools/extended.nix" {
        inherit pkgs;
        openclawToolPkgs = ocToolPkgs;
      }).toolNames;
    withTools =
      {
        toolNamesOverride ? null,
        excludeToolNames ? [ ],
      }:
      ocImport { inherit toolNamesOverride excludeToolNames; };
  };
in
{
  imports = [ oc.homeManagerModules.openclaw ];

  options.kp.openclaw = {
    enable = lib.mkEnableOption "OpenClaw personal AI assistant gateway";

    model = lib.mkOption {
      type = lib.types.str;
      default = "qwen2.5-coder-14b";
      description = lib.mdDoc ''
        Model id the agent uses. Must match the alias served by the local
        llama.cpp server (`kp.llm.llamaCpp.alias`).
      '';
    };

    contextWindow = lib.mkOption {
      type = lib.types.ints.positive;
      default = 8192;
      description = lib.mdDoc "Context window advertised to OpenClaw for the local model (keep in sync with `kp.llm.llamaCpp.contextSize`).";
    };

    reserveTokens = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      example = 8192;
      description = lib.mdDoc ''
        Tokens reserved for the model's response (`agents.defaults.compaction.reserveTokens`).
        With a small `contextWindow`, OpenClaw's default reserve (16384) leaves
        almost no room for the agent's ~7k system prompt; lower it so more of the
        window is usable for prompt/history. Output is capped at this many tokens.
      '';
    };

    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:8080/v1";
      description = lib.mdDoc "OpenAI-compatible endpoint of the local llama.cpp server.";
    };

    requestTimeoutSeconds = lib.mkOption {
      type = lib.types.ints.positive;
      default = 1200;
      description = lib.mdDoc ''
        Per-request timeout for the local model provider
        (`models.providers.<id>.timeoutSeconds`). Local inference is slow on the
        first request (full prompt prefill before llama.cpp's prompt cache warms
        up), so this defaults high to avoid premature timeouts.
      '';
    };

    agentTimeoutSeconds = lib.mkOption {
      type = lib.types.ints.positive;
      default = 1200;
      description = lib.mdDoc ''
        Overall agent-run timeout ceiling (`agents.defaults.timeoutSeconds`).
        Must exceed the first-request prefill time on slow local hardware,
        otherwise the run is aborted before llama.cpp's prompt cache warms up.
      '';
    };

    allowedTools = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = [
        "read"
        "write"
        "edit"
        "exec"
        "process"
        "dir_list"
        "dir_fetch"
        "file_fetch"
        "file_write"
      ];
      description = lib.mdDoc ''
        Restrict the agent's tool set (`tools.allow`). OpenClaw's full 28-tool
        catalog is ~9k tokens of schema, which dominates prefill on slow local
        hardware. This coding-focused subset roughly halves the prompt. Set to
        null to keep OpenClaw's full default tool set.
      '';
    };

    documents = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = lib.mdDoc "Optional documents dir (AGENTS.md/SOUL.md/TOOLS.md). When null, OpenClaw runs its bootstrap ritual.";
    };

    signal = {
      enable = lib.mkEnableOption "the Signal channel (requires signal-cli + a one-time link/register)";

      account = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "+15551234567";
        description = lib.mdDoc "Bot Signal number in E.164 format (a dedicated number is recommended).";
      };

      allowFrom = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "+15557654321" ];
        description = lib.mdDoc "Phone numbers (E.164) or `uuid:<id>` values allowed to DM the bot.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !needsHashPin || aarch64Hash != null;
        message = ''
          kp.openclaw: no aarch64-linux pnpmDepsHash pinned for OpenClaw ${ocVersion}.
          Build it once and add the hash to modules/home/openclaw.nix:
            nix build --impure --expr 'let f = builtins.getFlake (toString ./.); in (import "''${f.inputs.nix-openclaw}/nix/packages" { pkgs = f.nixosConfigurations.njord.pkgs; sourceInfo = import "''${f.inputs.nix-openclaw}/nix/sources/openclaw-source.nix"; openclawToolPkgs = f.inputs.nix-openclaw.inputs.nix-openclaw-tools.packages.aarch64-linux; qmdPackage = null; }).openclaw'
          and copy the "got:" hash from the FOD mismatch error.
        '';
      }
      {
        assertion = !cfg.signal.enable || cfg.signal.account != "";
        message = "kp.openclaw.signal.account must be set (E.164) when the Signal channel is enabled.";
      }
    ];

    # nixpkgs ships its own `openclaw` (marked insecure); the nix-openclaw HM
    # module probes `pkgs.openclaw` / `pkgs.openclawPackages`, which would force
    # that insecure derivation. Shadow them with our corrected aarch64 build set.
    nixpkgs.overlays = [
      (_final: _prev: {
        openclaw = openclawPackages.openclaw;
        inherit openclawPackages;
      })
    ];

    # signal-cli on the user's PATH for the one-time link/register flow.
    home.packages = lib.optionals cfg.signal.enable [ pkgs.signal-cli ];

    programs.openclaw = {
      enable = true;
      package = openclawPackages.openclaw;
      documents = cfg.documents;

      # Make signal-cli reachable from the gateway's PATH (channels.signal.cliPath).
      runtimePackages = lib.optionals cfg.signal.enable [ pkgs.signal-cli ];

      config = {
        # Loopback, single-user gateway: no gateway auth token needed. Channel
        # access is gated by Signal pairing/allowlist below.
        gateway = {
          mode = "local";
          bind = "loopback";
          auth.mode = "none";
        };

        # Local llama.cpp server as an OpenAI-compatible provider.
        models.providers.llamacpp = {
          api = "openai-completions";
          baseUrl = cfg.baseUrl;
          apiKey = "sk-local";
          timeoutSeconds = cfg.requestTimeoutSeconds;
          contextTokens = cfg.contextWindow;
          contextWindow = cfg.contextWindow;
          models = [
            {
              id = cfg.model;
              name = cfg.model;
              contextTokens = cfg.contextWindow;
              contextWindow = cfg.contextWindow;
              compat.supportsTools = true;
            }
          ];
        };

        tools = lib.mkIf (cfg.allowedTools != null) {
          allow = cfg.allowedTools;
        };

        agents.defaults = {
          model = "llamacpp/${cfg.model}";
          timeoutSeconds = cfg.agentTimeoutSeconds;
        }
        // lib.optionalAttrs (cfg.reserveTokens != null) {
          compaction.reserveTokens = cfg.reserveTokens;
        };

        channels = lib.mkIf cfg.signal.enable {
          signal = {
            enabled = true;
            account = cfg.signal.account;
            cliPath = "signal-cli";
            dmPolicy = "pairing";
            allowFrom = cfg.signal.allowFrom;
          };
        };
      };
    };

    # nix-openclaw defines the gateway user service without an [Install] section,
    # so it never gets pulled into a target and won't autostart. Wire it to the
    # session's default.target (robot has a graphical login on njord).
    systemd.user.services.${config.programs.openclaw.systemd.unitName}.Install.WantedBy = [
      "default.target"
    ];
  };
}
