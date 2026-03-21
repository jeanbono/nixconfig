# nixconfig

Configuration NixOS modulaire basée sur les **Nix Flakes** et **Home Manager**.

Chaque fonctionnalité est un module activable via une option `enable`, ce qui permet de **composer** chaque host à la carte.

Les modules sont **découverts automatiquement** : il suffit de déposer un fichier `.nix` dans `modules/system/` ou `modules/home/` pour qu'il soit importé (via `lib.nix`). Les modules organisés en sous-dossiers exposent un `default.nix` et sont référencés par un fichier `.nix` de même nom dans le dossier parent.

## Structure du projet

```
.
├── flake.nix                  # Point d'entrée — mkHost importe tous les modules
├── flake.lock
├── lib.nix                    # importDir — auto-discovery des modules (.nix réguliers)
├── wallpapers/                # Fonds d'écran
├── hosts/
│   └── furnace/               # Config spécifique au host "furnace"
│       ├── default.nix        #   Active les modules + config machine (boot, users, nix-ld…)
│       └── hardware-configuration.nix
├── home/
│   └── furnace/
│       └── pierre.nix         # Active les modules home pour l'utilisateur pierre
└── modules/
    ├── system/                # Modules NixOS (auto-discovery)
    │   ├── nix.nix            #   modules.system.nix
    │   ├── locale.nix         #   modules.system.locale
    │   ├── network.nix        #   modules.system.network
    │   ├── audio.nix          #   modules.system.audio
    │   ├── printing.nix       #   modules.system.printing
    │   ├── hyprland.nix       #   modules.system.hyprland
    │   ├── plasma.nix         #   modules.system.plasma  (mutuellement exclusif avec hyprland)
    │   ├── nvidia.nix         #   modules.system.nvidia
    │   ├── gaming.nix         #   modules.system.gaming
    │   ├── brave.nix          #   modules.system.brave  (policies + installation HM via .users)
    │   ├── protonpass.nix     #   modules.system.protonpass
    │   └── home-manager.nix   #   Intégration HM + sharedModules (plasma-manager, caelestia-shell)
    └── home/                  # Modules Home Manager (auto-discovery)
        ├── shell.nix          #   modules.home.shell
        ├── git.nix            #   modules.home.git
        ├── ssh.nix            #   modules.home.ssh
        ├── messaging.nix      #   modules.home.messaging
        ├── tools.nix          #   modules.home.tools
        ├── dev.nix            #   modules.home.dev
        ├── nvim.nix           #   modules.home.nvim
        ├── caelestia.nix      #   modules.home.caelestia
        ├── plasma.nix         #   modules.home.plasma
        ├── hyprland.nix       #   → hyprland/  (point d'entrée)
        ├── hyprland/          #   modules.home.hyprland — découpé en sous-modules
        │   ├── default.nix    #     option enable + assertion plasma
        │   ├── core.nix       #     compositor, moniteurs, keybinds, animations, screenshot
        │   ├── cursor.nix     #     curseur rose-pine-hyprcursor
        │   ├── scripts.nix    #     wallpaper.png
        │   ├── yazi.nix       #     gestionnaire de fichiers (thème Catppuccin)
        │   └── packages.nix   #     paquets complémentaires (grim, slurp, wl-clipboard…)
        ├── theme.nix          #   → theme/  (point d'entrée)
        └── theme/             #   Theming centralisé
            └── catppuccin.nix #     modules.home.theme.catppuccin
```

## Modules disponibles

### Système (`modules.system.*`)

| Option | Description |
|---|---|
| `modules.system.nix.enable` | Flakes, auto-optimise-store, GC hebdomadaire |
| `modules.system.locale.enable` | Locale `fr_FR.UTF-8`, clavier français |
| `modules.system.network.enable` | NetworkManager, SSH, curl, wget |
| `modules.system.audio.enable` | PipeWire (ALSA, PulseAudio, JACK) |
| `modules.system.printing.enable` | Impression (CUPS) — Brother DCP-1610W préconfigurée |
| `modules.system.hyprland.enable` | Hyprland (Wayland compositor) + portails XDG + polices + greetd/UWSM |
| `modules.system.plasma.enable` | KDE Plasma 6 + SDDM Wayland + polices *(exclusif avec hyprland)* |
| `modules.system.nvidia.enable` | Pilote NVIDIA, open kernel module, modesetting |
| `modules.system.gaming.enable` | Steam, Proton, MangoHud, Gamemode, Wine |
| `modules.system.brave.enable` | Policies Brave (uBlock, Catppuccin, ProtonPass) + installation HM via `brave.users` |
| `modules.system.protonpass.enable` | ProtonPass CLI + GUI + extension Brave (si brave activé) |

### Home Manager (`modules.home.*`)

| Option | Description |
|---|---|
| `modules.home.shell.enable` | Zsh (autosuggestion, syntaxe, Starship) + Alacritty (thème Catppuccin) |
| `modules.home.git.enable` | Git + Jujutsu (identité configurée, aliases tug) |
| `modules.home.ssh.enable` | SSH + agent ProtonPass CLI (service systemd user) |
| `modules.home.messaging.enable` | Vesktop (Discord + Vencord) + Element |
| `modules.home.tools.enable` | Paquets CLI (ripgrep, fd, jq, fastfetch, unzip) |
| `modules.home.dev.enable` | IntelliJ IDEA |
| `modules.home.nvim.enable` | IDE Neovim : LSP, blink.cmp, Treesitter, Telescope, thème lié à `theme.catppuccin` |
| `modules.home.caelestia.enable` | Caelestia shell (bar, launcher, lock, idle, wallpaper, notifications) + lock-on-start |
| `modules.home.hyprland.enable` | Compositor Hyprland, Yazi, screenshot (`SUPER+SHIFT+S`), curseur rose-pine *(exclusif avec plasma)* |

### Thème (`modules.home.theme.*`)

| Option | Description |
|---|---|
| `modules.home.theme.catppuccin.enable` | Thème Catppuccin (GTK, Hyprland, Alacritty, Yazi, Neovim) |
| `modules.home.theme.catppuccin.flavor` | Variante : `latte` / `frappe` / `macchiato` / `mocha` (défaut : `macchiato`) |
| `modules.home.theme.catppuccin.accent` | Couleur d'accent : `blue`, `mauve`, `green`… (défaut : `blue`) |

Le module theme expose des options calculées (`hyprlandThemeFile`, `alacrittyThemeFile`, `gtkThemeName`) consommées automatiquement par les autres modules. Changer `flavor` ou `accent` propage le thème dans Hyprland, Alacritty, GTK, Yazi **et Neovim**.

### Caelestia (`modules.home.caelestia.*`)

| Option | Type | Défaut | Description |
|---|---|---|---|
| `enable` | bool | — | Active caelestia-shell |
| `showBattery` | bool | `false` | Indicateur batterie dans la barre |
| `showWifi` | bool | `false` | Indicateur Wi-Fi dans la barre |
| `lockBeforeSleep` | bool | `false` | Verrouiller avant mise en veille |
| `roundingScale` | float | `0.6` | Arrondi des coins (0.0–1.0) |
| `desktopClock` | bool | `true` | Horloge sur le bureau |
| `idleTimeouts` | list | lock@5min, dpms@10min | Timeouts d'inactivité |

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
| **cachyos** | `xddxdd/nix-cachyos-kernel` (kernels optimisés) |
| **home-manager** | `nix-community/home-manager` (suit nixpkgs) |
| **NUR** | `nix-community/NUR` (suit nixpkgs) |
| **plasma-manager** | `nix-community/plasma-manager` (suit nixpkgs) |
| **caelestia-shell** | `caelestia-dots/shell` (bar, launcher, lock, notifications, wallpaper) |

## Host : `furnace`

Machine de bureau Intel + NVIDIA sous **Hyprland / Wayland**.

```nix
# hosts/furnace/default.nix
modules.system = {
  nix.enable = true;
  locale.enable = true;
  network.enable = true;
  audio.enable = true;
  printing.enable = true;
  hyprland.enable = true;
  hyprland.user = "pierre";
  nvidia.enable = true;
  gaming.enable = true;
  brave.enable = true;
  brave.users = [ "pierre" ];  # active programs.brave via HM
  protonpass.enable = true;
};

programs.zsh.enable = true;
```

```nix
# home/furnace/pierre.nix
modules.home = {
  shell.enable = true;
  git.enable = true;
  ssh.enable = true;
  messaging.enable = true;
  tools.enable = true;
  dev.enable = true;
  nvim.enable = true;
  hyprland.enable = true;
  caelestia.enable = true;  # bar, launcher, lock, idle, wallpaper, notifications
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
2. Créer `home/<nom>/<user>.nix` si besoin
3. Ajouter l'entrée dans `flake.nix` :
   ```nix
   nixosConfigurations.<nom> = mkHost "<nom>" "x86_64-linux";
   ```
4. Activer les modules souhaités dans le host :
   ```nix
   modules.system = {
     nix.enable = true;
     locale.enable = true;
     network.enable = true;
     # ... seulement ce dont la machine a besoin
   };
   ```
5. Rebuild : `sudo nixos-rebuild switch --flake .#<nom>`

### Ajouter un nouveau module

Créer un fichier `.nix` dans `modules/system/` ou `modules/home/` — il sera automatiquement importé par `lib.nix`. Pour un module avec plusieurs fichiers, créer un sous-dossier avec un `default.nix` et un fichier `.nix` de même nom dans le dossier parent qui l'importe.

### Exemple : serveur headless

```nix
# Seulement le strict nécessaire, pas d'audio/hyprland/gaming
modules.system = {
  nix.enable = true;
  locale.enable = true;
  network.enable = true;
};
```
