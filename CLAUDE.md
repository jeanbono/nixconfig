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
- `modules/hosts.nix` — declares which hosts and users exist: `den.hosts.x86_64-linux.furnace.users.pierre = {};`
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

### Cross-layer sharing: `flake.lib`

Values that need to be read from multiple aspect files (e.g. the Catppuccin flavor) are exposed via `flake.lib.<name>` in a proper flake-parts module (see `modules/theme.nix`), and consumed elsewhere via `inputs.self.lib.<name>` (needs `{ inputs, ... }:` in that file's signature). This replaced the old `nixosConfig`/`extraSpecialArgs` HM-cross-layer trick — a plain file exporting a bare function/attrset would break `import-tree` the same way an unprefixed `hardware-configuration.nix` would.

### Adding a new aspect

Create `modules/<name>.nix` with `den.aspects.<name> = { nixos = ...; homeManager = ...; };` — `import-tree` picks it up automatically. Then add `den.aspects.<name>` to `furnace.nix`'s `includes` (if it has a `nixos` field) and/or `pierre.nix`'s `includes` (if it has a `homeManager` field).

## Changeset descriptions (Jujutsu)

Format: `:gitmoji: description du changeset`. La description doit être rédigée **en anglais**, même si le reste de cette documentation est en français.

| Gitmoji | Quand l'utiliser |
|---|---|
| `:sparkles:` | Nouveau module ou nouvelle feature |
| `:wrench:` | Modification de config existante |
| `:bug:` | Correction d'un bug |
| `:recycle:` | Refacto sans changement fonctionnel |
| `:arrow_up:` | Mise à jour des flake inputs (`nix flake update`) |
| `:fire:` | Suppression de code ou de module |
| `:memo:` | Documentation (README, CLAUDE.md…) |
| `:lipstick:` | Changement de thème ou d'apparence |
| `:package:` | Ajout/suppression de paquets dans un module existant |
| `:construction:` | Travail en cours (WIP) |

### Adding a new host

1. Add `den.hosts.<system>.<hostname>.users.<username> = {};` to `modules/hosts.nix`.
2. Create `modules/<hostname>.nix` as the host aspect (mirror `modules/furnace.nix`), and `modules/<username>.nix` as the user aspect (mirror `modules/pierre.nix`) if it's a new user.
3. Rebuild: `sudo nixos-rebuild switch --flake .#<hostname>`
