# nixconfig

Configuration NixOS modulaire basée sur les **Nix Flakes** et **Home Manager**.

Chaque fonctionnalité est un module activable via une option `enable`, ce qui permet de **composer** chaque host à la carte.

Les modules sont **découverts automatiquement** : il suffit de déposer un fichier `.nix` ou un dossier dans `modules/system/` ou `modules/home/` pour qu'il soit importé (via `lib.nix`).

## Structure du projet

```
.
├── flake.nix                  # Point d'entrée — mkHost importe tous les modules
├── flake.lock
├── lib.nix                    # importDir — auto-discovery des modules
├── hosts/
│   └── furnace/               # Config spécifique au host "furnace"
│       ├── default.nix        #   Active les modules + config machine
│       └── hardware-configuration.nix
├── home/
│   └── furnace/
│       └── pierre.nix         # Config Home Manager de l'utilisateur pierre
└── modules/
    ├── system/                # Modules NixOS (auto-discovery)
    │   ├── core/              #   modules.system.core + modules.system.nix
    │   ├── desktop/           #   modules.system.plasma + modules.system.fonts
    │   ├── gpu/               #   modules.system.nvidia
    │   ├── gaming/            #   modules.system.gaming
    │   ├── home-manager/      #   Intégration Home Manager (toujours actif)
    │   └── shell/             #   modules.system.zsh + modules.system.kitty
    └── home/                  # Modules Home Manager (auto-discovery)
        ├── core.nix           #   modules.home.core
        ├── zsh.nix            #   modules.home.zsh
        ├── kitty.nix          #   modules.home.kitty
        └── plasma.nix         #   modules.home.plasma
```

## Modules disponibles

### Système (`modules.system.*`)

| Option | Description |
|---|---|
| `modules.system.core.enable` | Locale FR, NetworkManager, PipeWire, SSH, paquets de base |
| `modules.system.nix.enable` | Flakes, auto-optimise-store, GC hebdomadaire |
| `modules.system.plasma.enable` | KDE Plasma 6 + SDDM Wayland |
| `modules.system.fonts.enable` | Nerd Fonts (FiraCode, Symbols), Noto |
| `modules.system.nvidia.enable` | Pilote NVIDIA beta, open kernel module, modesetting |
| `modules.system.gaming.enable` | Steam, Proton, MangoHud, Gamemode, Wine |
| `modules.system.zsh.enable` | Zsh (niveau système) |
| `modules.system.kitty.enable` | Terminal Kitty (niveau système) |

### Home Manager (`modules.home.*`)

| Option | Description |
|---|---|
| `modules.home.core.enable` | Paquets CLI (ripgrep, fd, jq…), variables Wayland |
| `modules.home.zsh.enable` | Zsh avec autosuggestion, syntax highlighting, prompt custom |
| `modules.home.kitty.enable` | Kitty (thème sombre, opacité, padding) |
| `modules.home.plasma.enable` | Config Plasma côté user (placeholder) |

## Inputs du flake

| Input | Source |
|---|---|
| **nixpkgs** | `nixos-unstable` |
| **home-manager** | `nix-community/home-manager` (suit nixpkgs) |
| **NUR** | `nix-community/NUR` (suit nixpkgs) |

## Host : `furnace`

Machine de bureau Intel + NVIDIA sous KDE Plasma 6 / Wayland.

```nix
modules.system = {
  core.enable = true;
  nix.enable = true;
  plasma.enable = true;
  fonts.enable = true;
  nvidia.enable = true;
  gaming.enable = true;
  zsh.enable = true;
  kitty.enable = true;
};
```

- **Boot** : systemd-boot, kernel latest, module `atlantic`
- **Apps** : 1Password, IntelliJ IDEA, Brave (policies hardening), Discord, Zulip, Element
- **VCS** : Jujutsu (avec identité configurée), Git
- **SSH** : Agent 1Password (`~/.1password/agent.sock`)

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
     core.enable = true;
     nix.enable = true;
     # ... seulement ce dont la machine a besoin
   };
   ```
5. Rebuild : `sudo nixos-rebuild switch --flake .#<nom>`

### Ajouter un nouveau module

Il suffit de créer un fichier `.nix` (ou un dossier avec `default.nix`) dans le répertoire concerné :

- **Système** : `modules/system/<catégorie>/mon-module.nix`
- **Home** : `modules/home/mon-module.nix`

Le module sera automatiquement importé grâce à `lib.nix`. Il ne reste qu'à l'activer dans le host avec `modules.<system|home>.<nom>.enable = true;`.
