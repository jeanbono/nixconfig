# nixconfig

Configuration NixOS basée sur le framework [**den**](https://github.com/denful/den) (épinglé sur `v0.18.0`) : `flake-parts` + `import-tree` + `flake-file`, unifiant NixOS et Home Manager dans un seul arbre de modules.

## Architecture

Chaque fichier `modules/*.nix` déclare un ou plusieurs **aspects** (`den.aspects.<name>`), avec un champ `nixos` et/ou `homeManager` :

```nix
{
  den.aspects.foo = {
    nixos = { pkgs, ... }: { environment.systemPackages = [ pkgs.foo ]; };
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.foo-cli ]; };
  };
}
```

- `flake.nix` est **généré** par `flake-file` (`nix run .#write-flake`) à partir de `flake-file.inputs` déclaré dans `modules/dendritic.nix` — ne jamais l'éditer à la main.
- `modules/hosts.nix` déclare quels hosts/users existent : `den.hosts.x86_64-linux.furnace.users.pierre = {};`
- `modules/furnace.nix` (aspect **host**) et `modules/pierre.nix` (aspect **user**) contiennent chacun une liste `includes` — c'est elle qui "active" les aspects, pas une option `enable`.
- Un aspect touchant les deux couches est listé dans les deux `includes`.
- `modules/_nixos/hardware-configuration.nix` (module NixOS classique, pas flake-parts) : le préfixe `_` fait qu'`import-tree` l'ignore (convention den), il est importé explicitement dans `furnace.nix`.

## Structure du projet

```
.
├── flake.nix                # Généré par flake-file — ne pas éditer
├── flake.lock
├── wallpapers/
└── modules/
    ├── dendritic.nix         # Wiring den + flake-file, déclaration des inputs
    ├── defaults.nix          # stateVersion, allowUnfree, systems, HM useGlobalPkgs
    ├── hosts.nix              # den.hosts.<system>.<host>.users.<user>
    ├── furnace.nix            # Aspect host : hardware, boot, includes NixOS
    ├── pierre.nix             # Aspect user : batteries, includes HM
    ├── theme.nix              # flake.lib.theme (flavor, thème alacritty) + GTK dark
    ├── _nixos/
    │   └── hardware-configuration.nix  # Module NixOS brut, ignoré par import-tree (préfixe `_`)
    └── <feature>.nix          # Un aspect par feature (voir tableau ci-dessous)
```

## Aspects disponibles

| Aspect | Couche(s) | Description |
|---|---|---|
| `audio` | NixOS | PipeWire (ALSA, PulseAudio, JACK) |
| `locale` | NixOS | Locale `fr_FR.UTF-8`, clavier français |
| `network` | NixOS | NetworkManager, SSH, curl, wget |
| `nix` | NixOS | Flakes, auto-optimise-store, GC hebdomadaire |
| `nvidia` | NixOS | Pilote NVIDIA, modesetting |
| `gaming` | NixOS | Steam, Proton, MangoHud, Gamemode, Wine |
| `printing` | NixOS+HM | CUPS + SANE (Brother DCP-1610W) + simple-scan |
| `ollama` | NixOS | Service Ollama CUDA, préchargement modèle |
| `lmstudio` | NixOS+HM | Firewall port 1234 + LM Studio |
| `intellij` | NixOS+HM | Java (NixOS) + IntelliJ IDEA (HM) |
| `hyprland` | NixOS+HM | Compositor, greetd/UWSM, keybinds, moniteurs, yazi, curseur |
| `caelestia` | HM | Bar, launcher, lock, idle, wallpaper |
| `theme` | HM | Thème Catppuccin (GTK dark, `flake.lib.theme` partagé) |
| `alacritty` | HM | Terminal GPU Alacritty |
| `nvim` | HM | Neovim IDE : LSP, blink.cmp, Treesitter, Telescope |
| `zsh` | NixOS+HM | Zsh (autosuggestion, syntaxe) + Starship |
| `git` | HM | Git + signature SSH |
| `jujutsu` | HM | Jujutsu VCS (identité, signature SSH, alias tug) |
| `ssh` | HM | Config SSH cliente (agent ProtonPass) |
| `brave` | NixOS+HM | Policies Brave (uBlock, Catppuccin) + `programs.brave` |
| `protonpass` | NixOS+HM | CLI + GUI + agent SSH systemd + policy Brave |
| `messaging` | HM | Vesktop (Discord), Element, Cinny |
| `plex` | HM | Plex Desktop |
| `claude-code` | HM | Claude Code CLI |
| `tools` | HM | Paquets CLI (ripgrep, fd, jq, fastfetch, unzip) |

## Raccourcis clavier notables

| Raccourci | Action |
|---|---|
| `SUPER + Return` | Terminal (Alacritty) |
| `SUPER + D` | Lanceur caelestia |
| `SUPER + M` | Menu session caelestia |
| `SUPER + E` | Explorateur de fichiers (Yazi) |
| `SUPER + Q` | Fermer la fenêtre |
| `SUPER + F` | Plein écran |
| `SUPER + V` | Flottant |
| `SUPER + SHIFT + S` | Screenshot zone sélectionnable → `~/Pictures/Screenshots/` + presse-papier |
| `SUPER + ←/→/↑/↓` | Déplacer le focus |
| `SUPER + SHIFT + H/L/K/J` | Déplacer la fenêtre |
| `SUPER + SHIFT + ←/→` | Déplacer la fenêtre vers un autre moniteur |

## Host : `furnace`

Machine de bureau Intel + NVIDIA sous Hyprland/Wayland. Kernel CachyOS, `/mnt/data` (NTFS) monté automatiquement, nix-ld pour binaires standards.

## Utilisation

```bash
# Rebuild
sudo nixos-rebuild switch --flake .#furnace

# Mettre à jour les inputs
nix flake update

# Régénérer flake.nix après avoir modifié modules/dendritic.nix
nix run .#write-flake
```

### Ajouter un aspect

Créer `modules/<name>.nix` avec `den.aspects.<name> = { nixos = ...; homeManager = ...; };`, puis l'ajouter à `includes` dans `furnace.nix` et/ou `pierre.nix` selon la couche.

### Ajouter un nouveau host

1. Ajouter `den.hosts.<system>.<hostname>.users.<user> = {};` dans `modules/hosts.nix`
2. Créer `modules/<hostname>.nix` (aspect host, sur le modèle de `furnace.nix`)
3. Rebuild : `sudo nixos-rebuild switch --flake .#<hostname>`
