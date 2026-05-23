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
```

## Architecture

This config uses the **dendritic pattern**: flake-parts + Home Manager unified in a single module tree, so NixOS system config and Home Manager user config live in the same file.

### Entry points

- `flake.nix` — delegates entirely to `flake-module.nix` via `flake-parts.lib.mkFlake`
- `flake-module.nix` — auto-imports all `modules/*.nix` via `importTree`, defines `mkHost`, registers `flake.nixosConfigurations`
- `hosts/furnace/default.nix` — activates modules for the `furnace` machine; no module code lives here, only `modules.<x>.enable = true` declarations

### Module pattern

Every file in `modules/` is a standard NixOS module that exposes options under `modules.*` and can configure both the NixOS system (`config.*`) and Home Manager users (`config.home-manager.users.*`) in the same file. There is no `system/` vs `home/` split.

The pattern for a typical module:

```nix
{ pkgs, lib, config, ... }:
let cfg = config.modules.<name>; in
{
  options.modules.<name>.enable = lib.mkEnableOption "…";

  config = lib.mkIf cfg.enable {
    # NixOS system config
    environment.systemPackages = [ … ];

    # Home Manager config for all managed users
    home-manager.users = lib.genAttrs config.modules.users (_: {
      programs.<name>.enable = true;
    });
  };
}
```

`config.modules.users` (defined in `modules/users.nix`) is the list of users managed by HM modules. All HM modules iterate over it with `lib.genAttrs`.

### Cross-layer communication

HM modules access NixOS config via `nixosConfig` (passed as `extraSpecialArgs`). For example, `modules/alacritty.nix` reads `nixosConfig.modules.theme.catppuccin` to pick the right theme file. This is injected in `flake-module.nix`:

```nix
home-manager.extraSpecialArgs = { nixosConfig = config; };
```

### Adding a new module

Create `modules/<name>.nix` — `importTree` picks it up automatically. No registration needed.

## Changeset descriptions (Jujutsu)

Format: `:gitmoji: description du changeset`

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

1. Create `hosts/<name>/default.nix` and `hosts/<name>/hardware-configuration.nix`
2. Add to `flake-module.nix`: `flake.nixosConfigurations.<name> = mkHost { hostName = "<name>"; };`
3. Activate modules in `hosts/<name>/default.nix`
4. Rebuild: `sudo nixos-rebuild switch --flake .#<name>`
