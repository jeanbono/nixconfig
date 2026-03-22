# nixconfig

Configuration NixOS basée sur le **pattern dendritic** : [flake-parts](https://flake.parts/) + **Home Manager**.

## Architecture dendritic

Le [pattern dendritic](https://github.com/mightyiam/dendritic) unifie NixOS et Home Manager dans un seul arbre de modules :

- **Chaque fichier `modules/*.nix` est un module NixOS** qui peut configurer simultanément le système (`config.*`) et les utilisateurs (`config.home-manager.users.*`) dans le même fichier — plus de séparation `system/` vs `home/`
- `flake.nix` délègue entièrement à `flake-module.nix` via `flake-parts.lib.mkFlake`
- `flake-module.nix` auto-importe tous les fichiers de `modules/` via `importTree` et les passe à `nixosSystem` — plus de `default.nix` d'agrégation
- Les modules HM lisent la config NixOS (ex: `modules.theme.catppuccin`) via `nixosConfig` passé en `extraSpecialArgs`
- `modules.users` est l'option centrale qui déclare les utilisateurs gérés ; chaque module HM y itère via `lib.genAttrs`

## Structure du projet

```
.
├── flake.nix            # Point d'entrée — délègue à flake-module.nix via flake-parts
├── flake-module.nix     # importTree ./modules + mkHost + flake.nixosConfigurations
├── flake.lock
├── wallpapers/          # Fonds d'écran
├── hosts/
│   └── furnace/
│       ├── default.nix                 # Hardware + activation des modules features
│       └── hardware-configuration.nix
└── modules/             # Features unifiées NixOS+HM (un fichier = une feature)
    ├── users.nix        # option modules.users (liste des utilisateurs gérés)
    ├── nix.nix          # modules.nix
    ├── locale.nix       # modules.locale
    ├── network.nix      # modules.network
    ├── audio.nix        # modules.audio
    ├── printing.nix     # modules.printing
    ├── nvidia.nix       # modules.nvidia
    ├── gaming.nix       # modules.gaming
    ├── hyprland.nix     # modules.hyprland       (NixOS + HM : compositor, greetd, keybinds, yazi, curseur)
    ├── plasma.nix       # modules.plasma         (NixOS + HM : SDDM + plasma-manager)
    ├── brave.nix        # modules.brave          (NixOS policies + HM programs.brave)
    ├── protonpass.nix   # modules.protonpass     (NixOS+HM : CLI, GUI, agent SSH, policy Brave)
    ├── zsh.nix          # modules.zsh            (HM : zsh + starship)
    ├── alacritty.nix    # modules.alacritty      (HM : terminal GPU)
    ├── git.nix          # modules.git            (HM : git)
    ├── jujutsu.nix      # modules.jujutsu        (HM : jujutsu VCS)
    ├── ssh.nix          # modules.ssh            (HM : config SSH cliente)
    ├── messaging.nix    # modules.messaging      (HM : vesktop, element)
    ├── tools.nix        # modules.tools          (HM : ripgrep, fd, jq…)
    ├── intellij.nix     # modules.intellij       (NixOS java + HM : IntelliJ IDEA)
    ├── nvim.nix         # modules.nvim           (HM : neovim IDE complet)
    ├── caelestia.nix    # modules.caelestia      (HM : bar, launcher, lock, idle)
    └── theme.nix        # modules.theme.catppuccin (HM : GTK, curseur, icônes)
```

## Modules disponibles

Tous les modules exposent leurs options sous `modules.*` sans distinction NixOS/HM.

| Option | Couche | Description |
|---|---|---|
| `modules.users` | NixOS | Liste des utilisateurs gérés par les modules HM |
| `modules.nix.enable` | NixOS | Flakes, auto-optimise-store, GC hebdomadaire |
| `modules.locale.enable` | NixOS | Locale `fr_FR.UTF-8`, clavier français |
| `modules.network.enable` | NixOS | NetworkManager, SSH, curl, wget |
| `modules.audio.enable` | NixOS | PipeWire (ALSA, PulseAudio, JACK) |
| `modules.printing.enable` | NixOS | Impression (CUPS) — Brother DCP-1610W préconfigurée |
| `modules.nvidia.enable` | NixOS | Pilote NVIDIA, modesetting |
| `modules.gaming.enable` | NixOS | Steam, Proton, MangoHud, Gamemode, Wine |
| `modules.hyprland.enable` | NixOS+HM | Compositor + greetd/UWSM + keybinds, moniteurs, yazi, curseur, wallpaper |
| `modules.hyprland.user` | NixOS | Utilisateur pour l'auto-login greetd |
| `modules.plasma.enable` | NixOS+HM | KDE Plasma 6 + SDDM + plasma-manager *(exclusif avec hyprland)* |
| `modules.brave.enable` | NixOS+HM | Policies Brave (uBlock, Catppuccin) + `programs.brave` |
| `modules.protonpass.enable` | NixOS+HM | CLI + GUI + agent SSH systemd + policy Brave |
| `modules.zsh.enable` | HM | Zsh (autosuggestion, syntaxe) + Starship |
| `modules.alacritty.enable` | HM | Terminal GPU Alacritty (thème Catppuccin) |
| `modules.git.enable` | HM | Git |
| `modules.jujutsu.enable` | HM | Jujutsu VCS (identité, alias tug) |
| `modules.ssh.enable` | HM | Config SSH cliente (agent ProtonPass) |
| `modules.messaging.enable` | HM | Vesktop (Discord + Vencord) + Element |
| `modules.tools.enable` | HM | Paquets CLI (ripgrep, fd, jq, fastfetch, unzip) |
| `modules.intellij.enable` | NixOS+HM | Java (NixOS) + IntelliJ IDEA (HM) |
| `modules.nvim.enable` | HM | Neovim IDE : LSP, blink.cmp, Treesitter, Telescope |
| `modules.caelestia.enable` | HM | Caelestia shell (bar, launcher, lock, idle, wallpaper) |
| `modules.caelestia.showBattery` | HM | Indicateur batterie dans la barre |
| `modules.caelestia.showWifi` | HM | Indicateur Wi-Fi dans la barre |
| `modules.caelestia.lockBeforeSleep` | HM | Verrouiller avant mise en veille |
| `modules.caelestia.roundingScale` | HM | Arrondi des coins (défaut : `0.6`) |
| `modules.caelestia.desktopClock` | HM | Horloge sur le bureau (défaut : `true`) |
| `modules.caelestia.idleTimeouts` | HM | Timeouts d'inactivité (défaut : lock@5min, dpms@10min) |
| `modules.theme.catppuccin.enable` | HM | Thème Catppuccin (GTK, Hyprland, Alacritty, Yazi, Neovim) |
| `modules.theme.catppuccin.flavor` | HM | `latte` / `frappe` / `macchiato` / `mocha` (défaut : `macchiato`) |
| `modules.theme.catppuccin.accent` | HM | `blue`, `mauve`, `green`… (défaut : `blue`) |

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
| `SUPER + SHIFT + S` | **Screenshot zone sélectionnable** → `~/Pictures/Screenshots/` + presse-papier |
| `SUPER + ←/→/↑/↓` | Déplacer le focus |
| `SUPER + SHIFT + H/L/K/J` | Déplacer la fenêtre |

## Inputs du flake

| Input | Source |
|---|---|
| **nixpkgs** | `nixos-unstable` |
| **flake-parts** | `hercules-ci/flake-parts` (système de modules flake) |
| **cachyos** | `xddxdd/nix-cachyos-kernel` (kernels optimisés) |
| **home-manager** | `nix-community/home-manager` (suit nixpkgs) |
| **NUR** | `nix-community/NUR` (suit nixpkgs) |
| **plasma-manager** | `nix-community/plasma-manager` (suit nixpkgs) |
| **caelestia-shell** | `caelestia-dots/shell` (bar, launcher, lock, notifications, wallpaper) |

## Host : `furnace`

Machine de bureau Intel + NVIDIA sous **Hyprland / Wayland**.

```nix
# hosts/furnace/default.nix — tout en un seul endroit
modules.users = [ "pierre" ];

modules = {
  nix.enable = true;
  locale.enable = true;
  network.enable = true;
  audio.enable = true;
  printing.enable = true;
  nvidia.enable = true;
  gaming.enable = true;

  hyprland.enable = true;
  hyprland.user = "pierre";
  hyprland-home.enable = true;

  brave.enable = true;
  protonpass.enable = true;

  shell.enable = true;
  git.enable = true;
  ssh.enable = true;
  messaging.enable = true;
  tools.enable = true;
  dev.enable = true;
  nvim.enable = true;
  caelestia.enable = true;

  theme.catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "blue";
  };
};
```

- **Boot** : systemd-boot, kernel CachyOS latest, module `atlantic`
- **Compatibilité** : nix-ld activé pour binaires standards
- **Stockage** : Partition Windows `/mnt/data` montée automatiquement pour Steam

## Utilisation

### Rebuild NixOS

```bash
sudo nixos-rebuild switch --flake .#furnace
```

### Mettre à jour les inputs

```bash
nix flake update
```

### Ajouter un nouveau host

1. Créer `hosts/<nom>/default.nix` et `hosts/<nom>/hardware-configuration.nix`
2. Ajouter l'entrée dans `flake-module.nix` :
   ```nix
   flake.nixosConfigurations.<nom> = mkHost { hostName = "<nom>"; };
   ```
3. Activer les modules souhaités dans `hosts/<nom>/default.nix` :
   ```nix
   modules.users = [ "alice" ];
   modules = {
     nix.enable = true;
     locale.enable = true;
     network.enable = true;
     shell.enable = true;
     # ... seulement ce dont la machine a besoin
   };
   ```
4. Rebuild : `sudo nixos-rebuild switch --flake .#<nom>`

### Ajouter un nouveau module feature

Créer un fichier `.nix` dans `modules/` — il est automatiquement importé par `importTree` dans `flake-module.nix`. Le fichier est un module NixOS standard qui peut configurer à la fois le système et `home-manager.users` dans le même fichier.

### Exemple : serveur headless

```nix
modules.users = [];
modules = {
  nix.enable = true;
  locale.enable = true;
  network.enable = true;
};
```
