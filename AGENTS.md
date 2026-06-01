# AGENTS.md — Nixfiles

## Build / Lint / Test Commands

This is a NixOS/nix-darwin/Home Manager flake. All builds use `nixos-rebuild` via `just`.

### Primary commands (run with `just`)

| Command | Description |
|---------|-------------|
| `just build` | Build current host config (`nixos-rebuild build --flake .#`) |
| `just boot` | Build + set as boot default (requires sudo) |
| `just switch` | Build + activate immediately (requires sudo) |
| `just test` | Build + activate in a temporary system (requires sudo) |
| `just build-remote HOSTNAME` | Build a specific host (e.g. `just build-remote baldur`) |
| `just switch-remote FQDN` | Build + activate on a remote host (detects arch for local/remote build) |
| `just build-iso-arm` | Build ARM ISO (`nix build .#nixosConfigurations.iso-arm.config.system.build.isoImage`) |
| `just build-iso-x86` | Build x86 ISO |

### Raw nix commands

```sh
# Build any host
nix build .#nixosConfigurations.<host>.config.system.build.toplevel

# Build macOS (nix-darwin)
nix build .#darwinConfigurations.njord-mac.system

# Run a specific app from packages
nix run .#<package-name>

# Enter a dev shell (if any module defines one)
nix develop
```

### Linting / Formatting

- **Nix formatter**: `nixfmt` (run manually: `nixfmt <file>.nix`)
- **Language servers** (nixd / nil) are configured in Home Manager for editor integration
- **No automated linter or CI pipeline** — there are no lint/test scripts or CI configs. Manually verify Nix syntax with `nix-instantiate --parse <file>.nix`.
- **There are no unit tests, no test framework, and no CI**. Test changes by building: `just build` or `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.

### Checking a single module

```sh
nix-instantiate --parse modules/nixos/<module>.nix   # syntax check only
nix eval .#nixosConfigurations.<host>.config.kp.<module>  # evaluate option value
```

---

## Code Style Guidelines

### General

- **Indentation**: 2 spaces for `.nix`, `.yaml`, `.yml`, `.tf`, `.lua` files; 4 spaces for everything else. LF line endings, UTF-8, trailing whitespace trimmed (except `.md`).
- **Semantic newlines**: In Nix, break after `{`, after `=`, after `;`, and align nested attribute sets logically.
- **Comments**: Minimal. Use only when the "why" is non-obvious. No block comments for non-functional code.
- **Semicolons**: Required at end of every Nix statement/assignment.

### Nix Module Structure

```nix
{ config, lib, pkgs, domain, ... }:  # destructure specialArgs explicitly
let
  cfg = config.kp.<moduleName>;        # always alias config.kp.* to cfg
in
{
  options.kp.<moduleName> = {
    enable = lib.mkEnableOption "description";
    # sub-options grouped by feature
    feature = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Whether to enable ...";
      };
      someString = lib.mkOption {
        type = lib.types.str;
        default = "default-val";
        example = "example-val";
        description = lib.mdDoc "What this does";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # service configs, sops secrets, impermanence dirs, reverse proxy, etc.
    services.foo.enable = true;
  };
}
```

### Naming Conventions

- **Files & attributes**: kebab-case (`reverse-proxy.nix`, `dns-server.nix`, `home-assistant.nix`)
- **Nix variables**: camelCase (`cfg`, `mediaBasePath`, `computeBasePath`, `wireguardInterface`)
- **Custom option namespace**: `kp.*` (short for "KongrooParadox") — all project-specific options live under `kp`
- **Host names**: lowercase single-word Norse mythology names (`baldur`, `midgard`, `asgard`, `yggdrasil`)
- **Workgroup names**: `UPPER_SNAKE_CASE` (`SKYNET`, `CASA_ANITA`)

### Imports / Module Composition

- Each module is a single file under `modules/nixos/`, `modules/home/`, or `modules/nix-darwin/`
- Host configs (`hosts/<name>/default.nix`) are thin: just `imports` + `kp.*` attribute assignments
- Use `inputs.<flake-input>.nixosModules.<name>` for external module references
- Use `./relative/path` for internal modules
- `default.nix` acts as the directory entry point (e.g., `modules/nixos/default.nix` collects all submodules)

### Lib Idioms

| Pattern | When to use |
|---------|-------------|
| `lib.mkIf cond { ... }` | Guard config blocks behind a boolean option |
| `lib.mkMerge [ ... ]` | Compose multiple conditional config blocks |
| `lib.mkDefault val` | Set a value with default priority (user overridable) |
| `lib.mkForce val` | Force a value (override other modules) |
| `lib.mkOption { type = ...; default = ...; description = lib.mdDoc "..."; }` | Declare an option |
| `lib.mkEnableOption "desc"` | Shorthand for boolean enable option |
| `lib.types.bool / str / lines / path / port` | Common types |
| `lib.mdDoc "..."` | Wrap all option descriptions |
| `lib.optionals cond [ ... ]` | Conditionally include list elements |
| `lib.strings.hasPrefix prefix str` | String prefix check |

### Error Handling (Nix)

- Use `lib.assertMsg` / `builtins.abort` for critical preconditions in `let` bindings
- Prefer `lib.mkIf` over assertions for graceful disable behavior
- Define sensible `default` values rather than forcing users to set every option
- Use `lib.types` with `check` functions for input validation when needed

### Secrets (SOPS)

- Secrets are encrypted in `secrets/secrets.yaml` with SOPS (age keys)
- Referenced as `config.sops.secrets."<path>".path` in modules
- Declare in module: `sops.secrets."service/key" = { mode = "0440"; group = "media"; };`
- `.sops.yaml` maps which keys can decrypt which paths

### Impermanence

- Ephemeral root setups use `kp.impermanence.extraDirectories` / `extraFiles` options
- Pattern: `kp.impermanence = lib.mkIf config.kp.impermanence.enable { extraDirectories = [ ... ]; };`

### Version Control

- **Primary VCS**: `jj` (Jujutsu) with git backend — use only `jj` for commits, amend, rebase, etc.
- **Git fallback**: available but avoid for history manipulation
- **Signing**: OpenPGP key `2CD046115D337861`, sign by default
- **User**: Guillaume Nanty <7790572+KongrooParadox@users.noreply.github.com>
- **Default branch**: `main`

### Workflow (jj)

- **`todo.md` is a bug tracker** and must **never** be pushed to remote. It sits at the top of local history.
- **Split agent changes into separate commits** by logical unit (one per module/feature).
- All agent work is done directly in the `todo.md` (bug-hunt) change.
- **Use `jj split` to carve changes into their own commit** — see below.
- **Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)**:
  `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `style:`, `perf:`. Lowercase after the colon, no period at the end.
- Push only when the user explicitly asks.

#### Using `jj split` with filesets

Make all changes in the working copy (which is the `todo.md` change). Once done, use `jj split` to separate logical units:

```sh
jj split -m 'type: short description of what this does' <FILE_OR_GLOB>
```

**Key behavior**: the file(s) matched by the fileset stay in the **original commit (become the parent)**. Everything else (including `todo.md`) moves to a **new child commit on top**.

Example — after creating AGENTS.md in the `todo.md` change:

```
@     [todo.md + AGENTS.md]        ← working copy, both files present
│
$ jj split -m 'docs: add AGENTS.md' AGENTS.md
│
P     [AGENTS.md, "docs: add AGENTS.md"] ← parent: matched fileset stays here
│
C     [todo.md, "bug-hunt"]              ← child:  everything else (todo.md) on top
```

Push only on explicit request:

```sh
jj bookmark set develop
jj git push --remote-only -b develop
```

- Never push to `main` directly.

### flake.nix Conventions

- `inputs` block: stable nixpkgs first, unstable follows, then specific flake inputs
- `outputs` block: `darwinConfigurations` before `nixosConfigurations`, alphabetically within each
- Each host block: `specialArgs` (domain, host, users, stateVersion, workgroup, isUnstable, isLinux, usesDisplaylink, inherit self impermanence inputs) followed by `modules` list
- `overlays` imported from `./overlays/`; `homeManagerModules.default` from `./modules/home`
