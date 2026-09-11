# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Apply configuration to the current host
sudo nixos-rebuild switch --flake .#furnace

# Update all flake inputs
nix flake update

# Evaluate without switching (dry run)
sudo nixos-rebuild dry-activate --flake .#furnace

# Check flake outputs
nix flake show

# Regenerate flake.nix after editing flake-file.inputs in modules/dendritic.nix
nix run .#write-flake
```

## Architecture

This config uses the [**den**](https://github.com/denful/den) flake framework (pinned to tag `v0.18.0`), built on flake-parts + `import-tree` + `flake-file`. NixOS system config and Home Manager user config live in the same tree, split into **aspects** rather than boolean-toggled modules.

### Entry points

- `flake.nix` — **auto-generated** by `flake-file` from `flake-file.inputs` declared in `modules/dendritic.nix`. Never edit it by hand; run `nix run .#write-flake` after changing inputs.
- `modules/dendritic.nix` — imports `flake-file` and `den`'s dendritic flake-parts modules, declares all flake inputs.
- `modules/defaults.nix` — flake-wide defaults: `system.stateVersion`, `home.stateVersion`, `nixpkgs.config.allowUnfree`, `home-manager.{useGlobalPkgs,useUserPackages}`, `systems`. Feature-specific Home Manager modules are imported in their owning aspects (`caelestia.nix`, `nvim.nix`).
- `modules/hosts.nix` — declares which hosts and users exist: `den.hosts.x86_64-linux.furnace.users.pierre = {};`. The host/user entries take arbitrary extra fields (freeform) beyond the ones den's schema declares — see "Per-entity data" below.
- `modules/furnace.nix` — the **host aspect** for `furnace`: hardware import, boot/kernel and its CachyOS binary cache, networking, and an `includes` list of every NixOS-facing aspect active on this machine.
- `modules/pierre.nix` — the **user aspect** for `pierre`: `den.batteries.*` (user account creation, shell) and an `includes` list of every Home-Manager-facing aspect active for this user.
- `modules/_nixos/hardware-configuration.nix` — plain NixOS module (nixos-generate-config output), imported by `furnace.nix`. Lives under the den-recommended `_nixos/` convention: `import-tree` ignores any path containing a `/_` segment, so this raw NixOS module (`environment.systemPackages` etc. aren't valid flake-parts options) never gets scanned as an aspect — it's only pulled in explicitly via `furnace.nix`'s `nixos.imports`.

### Aspect pattern

Every feature file in `modules/` declares a `den.aspects.<name>` with `nixos` and/or `homeManager` fields:

```nix
{
  den.aspects.foo = {
    nixos = { pkgs, ... }: { environment.systemPackages = [ pkgs.foo ]; };
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.foo-cli ]; };
  };
}
```

- `nixos` only takes effect when the aspect is included on a **host** (directly or via that host's `includes`).
- `homeManager` only takes effect when the aspect is included on a **user** (directly or via that user's `includes`).
- Activate a feature by adding `den.aspects.<name>` to the host and/or user `includes`. A feature touching both layers is listed in both places.
- `{ den, ... }:` is only needed in a file's top-level signature when it references `den.batteries.*`/`den.aspects.*`/`den.lib.*`; otherwise `{ ... }:` or `{ pkgs, lib, ... }:` suffices.

### Per-entity data: `{ user, host, ... }`

Data that belongs to a specific host or user (screens/GPU quirks, name/email/signing key…) is declared as extra fields directly on that entity in `modules/hosts.nix`:

```nix
den.hosts.x86_64-linux.furnace = {
  hyprland.monitors = [ { output = "DP-1"; ...; } ];
  users.pierre.email = "pierre@example.com";
};
```

den injects the resolved entity as a `{ user, host, ... }` module arg into every aspect's `nixos`/`homeManager` function it resolves for (`nixos` gets `host` only — a host has many users, so there's no single "current user"; `homeManager` gets both). Read it directly (`host.hyprland.monitors`, `user.email`).

Identity that's permanent and host-independent (a user's `fullName`/`email`/`signingKey`) should be a `let`-bound value in `hosts.nix`, assigned to `users.<name>` on every host that user has an account on — not duplicated per host. See the `pierre` binding at the top of `hosts.nix`.

### Typing per-entity data: `den.schema.<kind>.imports`

The entity types (`den.schema.user`, `den.schema.host`) accept freeform fields. `modules/schema.nix` declares typed identity and Hyprland options through `den.schema.user.imports` and `den.schema.host.imports`:

```nix
{ lib, den, ... }:
{
  den.schema.user.imports = [ { options.fullName = lib.mkOption { type = lib.types.str; }; } ];
  den.schema.host.imports = [ { options.hyprland = lib.mkOption { type = lib.types.submodule { ... }; default = { }; }; } ];
}
```

The Hyprland submodule rejects unknown keys such as `monitorss`. Keep typing focused on shared or structurally important fields; monitor and workspace entry shapes remain flexible.

### Cross-layer sharing: `flake.lib`

Values shared across aspects that do not belong to a host or user (e.g. the Catppuccin flavor) belong in `flake.lib.<name>`. Declare them in a flake-parts module and consume them through `inputs.self.lib.<name>`, as in `modules/theme.nix`.

`flake.lib` is raw and non-mergeable by default. If another module needs to contribute to it, first declare `options.flake.lib = lib.mkOption { type = lib.types.lazyAttrsOf lib.types.raw; };`.

Keep direct aspect dependencies local:

- An aspect can enrich another aspect's configuration: `protonpass.nix` sets SSH's `IdentityAgent`, while `ssh.nix` remains a generic client configuration.
- Give shared managed resources one owner. `brave.nix` owns the complete `ExtensionSettings` policy because Chromium does not safely merge it across separate policy files. Document that ownership with a short cross-reference.

### Adding a new aspect

Create `modules/<name>.nix` with `den.aspects.<name> = { nixos = ...; homeManager = ...; };` — `import-tree` picks it up automatically. Then add `den.aspects.<name>` to `furnace.nix`'s `includes` (if it has a `nixos` field) and/or `pierre.nix`'s `includes` (if it has a `homeManager` field).

## Changeset descriptions (Jujutsu)

Format: `:gitmoji: description of the changeset`. The description must be written **in English**.

| Gitmoji | When to use it |
|---|---|
| `:sparkles:` | New module or new feature |
| `:wrench:` | Change to existing config |
| `:bug:` | Bug fix |
| `:recycle:` | Refactor with no functional change |
| `:arrow_up:` | Flake input update (`nix flake update`) |
| `:fire:` | Removal of code or a module |
| `:memo:` | Documentation (README, CLAUDE.md…) |
| `:lipstick:` | Theme or appearance change |
| `:package:` | Adding/removing packages in an existing module |
| `:construction:` | Work in progress (WIP) |

### Adding a new host

1. Add `den.hosts.<system>.<hostname>.users.<username> = ...;` to `modules/hosts.nix` — reuse an existing identity `let` binding for a user who already has one elsewhere, rather than duplicating `fullName`/`email`/`signingKey`.
2. Create `modules/<hostname>.nix` as the host aspect (mirror `modules/furnace.nix`), and `modules/<username>.nix` as the user aspect (mirror `modules/pierre.nix`) if it's a new user.
3. Rebuild: `sudo nixos-rebuild switch --flake .#<hostname>`
