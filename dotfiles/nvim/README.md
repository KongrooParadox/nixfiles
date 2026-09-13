# Neovim config notes

## Nix LSP capability split

Two Nix language servers run side by side on every `.nix` buffer, and
capabilities are hand-partitioned between them in `lua/plugins/lsp.lua`.

They are complementary rather than redundant:

- **nil** parses statically. It knows the builtins manual and infers types for
  local bindings, but never evaluates Nix, so anything reached through `lib`,
  `pkgs` or the module system is invisible to it.
- **nixd** links against the Nix libraries and actually evaluates. It resolves
  `lib`, `pkgs` and NixOS/home-manager options with real documentation, but
  gives up on builtins and locally inferred types.

Neither is a superset of the other for hover, so each capability goes to
whichever server can genuinely answer it.

### Capability ownership

What is actually enabled after `on_attach`, measured live rather than read off
the source.

| Capability | nil | nixd | Why |
| --- | --- | --- | --- |
| `hoverProvider` | yes | yes | Deliberately both — see below |
| `definitionProvider` | no | yes | nixd resolves locals *and* jumps into nixpkgs sources |
| `completionProvider` | no | yes | Only nixd can enumerate `pkgs`, `lib` and options |
| `documentFormattingProvider` | yes | no | Single formatter owner; but see the note below |
| `codeActionProvider` | yes | no | nil has the richer quickfix set for syntax/legacy warnings |
| `renameProvider` | yes | no | Scope-accurate rename needs nil's static binding analysis |
| `referencesProvider` | yes | no | Same static analysis |
| `documentSymbolProvider` | yes | no | Same |
| `documentHighlightProvider` | yes | no | Same |
| `inlayHintProvider` | yes | no | nil's inferred types are more useful than nixd's package versions |
| `selectionRangeProvider` | yes | — | nil only; nixd does not offer it |
| `foldingRangeProvider` | — | yes | nixd only; nil does not offer it |
| `semanticTokensProvider` | yes | yes | Overlap, not arbitrated — see Known overlaps |
| `documentLinkProvider` | yes | yes | Overlap, not arbitrated — see Known overlaps |

**Formatting note.** `documentFormattingProvider` is nominally nil's, but
`conform.nvim` now owns `.nix` through `formatters_by_ft.nix = { "nixfmt" }`, so
`<leader>f` and format-on-save invoke `nixfmt` directly. nil's LSP formatting is
only reached via conform's `lsp_format = "fallback"` path. nil needs
`settings["nil"].formatting.command` set for that fallback to do anything — note
the config key is literally `"nil"`, not the lspconfig server name `nil_ls`.

**Why hover stays on both.** `vim.lsp.buf.hover()` uses `buf_request_all`: it
queries every attached client and discards `null` and empty replies before
rendering. Since exactly one of the two servers answers for any given symbol,
the union arrives as a single clean float with no duplication.

### Advertised capabilities

What each server is *able* to do, from its raw `initialize` response — distinct
from what this config chooses to use above. Re-check after an upgrade.

Measured against **nil `2026-07-23`** and **nixd `2.9.2`**.

| Capability | nil | nixd |
| --- | --- | --- |
| `hoverProvider` | yes | yes |
| `completionProvider` | yes — triggers `.` `?` | yes — trigger `.`, **plus `resolveProvider`** |
| `definitionProvider` | yes | yes |
| `referencesProvider` | yes | yes |
| `renameProvider` | yes — `prepareProvider` | yes — `prepareProvider` |
| `documentSymbolProvider` | yes | yes |
| `documentHighlightProvider` | yes | yes |
| `documentFormattingProvider` | yes | yes |
| `inlayHintProvider` | yes | yes |
| `codeActionProvider` | yes — plain | yes — kinds + `resolveProvider` |
| `documentLinkProvider` | yes — `resolveProvider` | yes |
| `semanticTokensProvider` | yes — always | yes — only with `--semantic-tokens` |
| `selectionRangeProvider` | yes | no |
| `foldingRangeProvider` | no | yes |
| `signatureHelpProvider` | **no** | **no** |

nixd's `semanticTokensProvider` appears only because `cmd` passes
`--semantic-tokens=true`; without the flag nixd does not advertise it.

### Measured behaviour

The evidence for the split. Same cursor positions, both servers.

#### Hover

| Symbol under cursor | nil | nixd |
| --- | --- | --- |
| `builtins.readFile` | `path → string` + manual text | null |
| `builtins.map` | `(? → ?) → [?] → [?]` + docs + example | null |
| local `myAdd = x: x + 1` | inferred `int → int` | null |
| inherited `mkIf` | `?` (unresolved) | null |
| `lib.strings.concatMapStrings` | null | description + per-argument `# Inputs` |
| `lib.optionalString` | null | full RFC-145 doc-comment |
| `pkgs.hello` | null | `hello-2.12.3`, homepage, description |
| `services.openssh.enable` | null | `bool (boolean)` + option description |

Zero overlap: nil covers builtins and locals, nixd covers everything derived
from nixpkgs. nil is the only one that reports a *type signature*; nixd reports
prose pulled from nixpkgs doc-comments.

#### Goto definition

| Symbol under cursor | nil | nixd |
| --- | --- | --- |
| local `myAdd` | same file, line 5 | same file, line 5 |
| inherited `mkIf` | same file, line 2 | same file, line 2 |
| `lib.optionalString` | null | `<nixpkgs>/lib/strings.nix:775` |
| `pkgs.hello` | null | `<nixpkgs>/pkgs/by-name/he/hello/package.nix:57` |

Here nixd *is* a strict superset, which is why definition is assigned to it
outright rather than shared.

### Known overlaps

The split is not perfectly clean. These are served by both servers:

| Overlap | Status |
| --- | --- |
| `hover` | Intentional — the two never answer for the same symbol |
| `semanticTokens` | Unarbitrated. nil always advertises it, nixd does because of `--semantic-tokens=true` |
| `documentLink` | Unarbitrated. Both advertise it, neither is disabled |
| diagnostics | Both publish. Push-based via `textDocument/publishDiagnostics`, so it never appears in `server_capabilities` and the `on_attach` partition cannot touch it |

### Not available from either

| Capability | Note |
| --- | --- |
| `signatureHelpProvider` | **Neither server implements it.** Hover on `K` is the signature mechanism for Nix, and blink's `signature = { enabled = true }` is inert on `.nix` buffers |
| `typeDefinitionProvider` | Not implemented |
| `implementationProvider` | Not implemented |
| `declarationProvider` | Not implemented |
| `codeLensProvider` | Not implemented |
| `callHierarchyProvider` | Not implemented |
| `workspaceSymbolProvider` | Not implemented |

The only tool that would give real inferred type signatures on hover is
[`JRMurr/tix`](https://github.com/JRMurr/tix), a static type checker for Nix
built on MLsub. It ships an LSP (`tix lsp`) but is explicitly experimental, and
it works from generated stubs rather than evaluation.

### nixd flake resolution

nixd has to be told what to evaluate. `lua/plugins/lsp.lua` resolves this per
project in `before_init`, in three tiers:

| Where you are editing | `pkgs` / `lib` source | Host options |
| --- | --- | --- |
| Inside this nixfiles checkout | its own nixpkgs input, local path | yes — nixos/darwin + home-manager |
| Inside any other flake | that flake's nixpkgs input | no |
| No flake at all | `<nixpkgs>` | no |

The nixpkgs input name is discovered rather than hardcoded (`nixpkgs`,
`nixpkgs-unstable`, `nixpkgs-stable`, `unstable`, falling back to `<nixpkgs>`),
and the host is resolved from `vim.uv.os_gethostname()` against the platform's
configuration set, falling back to the flake's first host.

`NIXFILES_DIR` (exported from `modules/home/editor.nix`) overrides detection, so
tier 1 applies even to `.nix` files outside the repo.

A local flake path is evaluated with git semantics: tracked edits are picked up,
but brand new **untracked** files stay invisible to nixd until `git add`.
