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
- `modules/defaults.nix` — flake-wide defaults: `system.stateVersion`, `home.stateVersion`, `nixpkgs.config.allowUnfree`, `home-manager.{useGlobalPkgs,useUserPackages,sharedModules}`, `systems`.
- `modules/hosts.nix` — declares which hosts and users exist: `den.hosts.x86_64-linux.furnace.users.pierre = {};`. The host/user entries take arbitrary extra fields (freeform) beyond the ones den's schema declares — see "Per-entity data" below.
- `modules/furnace.nix` — the **host aspect** for `furnace`: hardware import, boot/kernel, networking, and an `includes` list of every NixOS-facing aspect active on this machine.
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
- There is **no `enable` option** and no `lib.genAttrs config.modules.users`. "Activating" a feature means adding `den.aspects.<name>` to `furnace.nix`'s `includes` (for `nixos`) and/or `pierre.nix`'s `includes` (for `homeManager`). A feature touching both layers is listed in both places.
- `{ den, ... }:` is only needed in a file's top-level signature when it references `den.batteries.*`/`den.aspects.*`/`den.lib.*`; otherwise `{ ... }:` or `{ pkgs, lib, ... }:` suffices.

### Per-entity data: `{ user, host, ... }`

Data that belongs to a specific host or user (screens/GPU quirks, name/email/signing key…) is declared as extra fields directly on that entity in `modules/hosts.nix`, not invented as a separate cross-cutting mechanism:

```nix
den.hosts.x86_64-linux.furnace = {
  hyprland.monitors = [ { output = "DP-1"; ...; } ];
  users.pierre.email = "pierre@example.com";
};
```

den injects the resolved entity as a `{ user, host, ... }` module arg into every aspect's `nixos`/`homeManager` function it resolves for (`nixos` gets `host` only — a host has many users, so there's no single "current user"; `homeManager` gets both). Read it directly (`host.hyprland.monitors`, `user.email`) — no registry file, no `flake.lib` needed for this.

Identity that's permanent and host-independent (a user's `fullName`/`email`/`signingKey`) should be a `let`-bound value in `hosts.nix`, assigned to `users.<name>` on every host that user has an account on — not duplicated per host. See the `pierre` binding at the top of `hosts.nix`.

### Typing per-entity data: `den.schema.<kind>.imports`

The entity types (`den.schema.user`, `den.schema.host`) are `strict = false` — they accept arbitrary extra fields beyond what's declared, so a typo like `host.hyprland.monitorss` would otherwise silently evaluate to an unused extra key while `host.hyprland.monitors` stays at its default, with no error anywhere. `modules/schema.nix` types the fields that are actually load-bearing (identity, the major Hyprland knobs) by adding `lib.mkOption`-declared options via `den.schema.user.imports`/`den.schema.host.imports`:

```nix
{ lib, den, ... }:
{
  den.schema.user.imports = [ { options.fullName = lib.mkOption { type = lib.types.str; }; } ];
  den.schema.host.imports = [ { options.hyprland = lib.mkOption { type = lib.types.submodule { ... }; default = { }; }; } ];
}
```

A submodule option (unlike the top-level entity) is strict by default, so an unknown key inside it — `host.hyprland.monitorss` — is rejected outright at eval time with a "did you mean…" suggestion, instead of falling back silently. Don't type everything: only fields with a real typo/fallback-hiding risk, used across aspects, or otherwise structurally important — see the comment at the top of `schema.nix`.

### Cross-layer sharing: `flake.lib`

Values that aren't tied to one host/user entity, but still need to be read from multiple aspect files regardless of layer (e.g. the Catppuccin flavor) are exposed via `flake.lib.<name>` in a proper flake-parts module (see `modules/theme.nix`), and consumed elsewhere via `inputs.self.lib.<name>` (needs `{ inputs, ... }:` in that file's signature). This replaced the old `nixosConfig`/`extraSpecialArgs` HM-cross-layer trick — a plain file exporting a bare function/attrset would break `import-tree` the same way an unprefixed `hardware-configuration.nix` would.

`flake.lib` itself has no type declared by flake-parts, so it defaults to a raw, non-mergeable value: a second module setting a different `flake.lib.<name>` key fails with "option `flake.lib' is defined multiple times... expected to be unique." Only `theme.nix` uses it today — if a second `flake.lib.<name>` contributor shows up, declare `options.flake.lib = lib.mkOption { type = lib.types.lazyAttrsOf lib.types.raw; };` somewhere first (a `modules/flake-lib.nix` was added and removed for this in a past session, when a second contributor came and went).

A plain aspect-to-aspect implementation detail that isn't per-entity data or genuinely cross-layer doesn't need either mechanism. Two patterns depending on the actual coupling:

- **One aspect owns a resource, another merely enriches it when both happen to be active** (e.g. `protonpass.nix` sets `programs.ssh.settings."*".identityAgent` — `ssh.nix` itself stays generic and never mentions Proton Pass, works standalone, and the setting is simply inert if `ssh.nix` isn't included). Prefer this when the dependency direction is real (SSH doesn't need Proton Pass; Proton Pass has something to add to SSH).
- **A hardcoded value neither aspect can cleanly own without inventing a coupling that isn't real** (e.g. `brave.nix`/`protonpass.nix`'s ExtensionSettings — Chromium's own docs say merging the same managed policy from two files is undefined behavior, so exactly one file must own the whole value) — a short cross-referencing comment in both files is enough; don't reach for `flake.lib` just to avoid it.

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
