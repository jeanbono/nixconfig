# nixconfig

Configuration NixOS modulaire basée sur les **Nix Flakes** et **Home Manager**.

## Structure du projet

```
.
├── flake.nix                  # Point d'entrée du flake
├── flake.lock
├── hosts/
│   └── furnace/               # Configuration spécifique au host "furnace"
│       ├── default.nix        #   Assemblage des modules + config host
│       └── hardware-configuration.nix
├── home/
│   └── furnace/
│       └── pierre.nix         # Config Home Manager de l'utilisateur pierre
└── modules/
    ├── system/                # Modules NixOS (niveau système)
    │   ├── core/              #   Locale FR, réseau, audio (PipeWire), SSH, paquets de base
    │   │   └── nix.nix        #   Flakes activés, GC auto hebdo, optimisation du store
    │   ├── desktop/           #   KDE Plasma 6 + Wayland (SDDM), polices (Nerd Fonts, Noto)
    │   ├── gpu/               #   Pilote NVIDIA (beta, open, modesetting)
    │   ├── gaming/            #   Steam, Proton, MangoHud, Gamemode, Wine
    │   ├── home-manager/      #   Intégration Home Manager en tant que module NixOS
    │   └── shell/             #   Zsh + Kitty (niveau système)
    └── home/                  # Modules Home Manager (niveau utilisateur)
        ├── core.nix           #   Paquets CLI (ripgrep, fd, jq…), variables Wayland
        ├── zsh.nix            #   Zsh avec autosuggestion, syntax highlighting, prompt custom
        ├── kitty.nix          #   Terminal Kitty (thème sombre, opacité, padding)
        └── plasma.nix         #   Placeholder pour config Plasma côté user
```

## Inputs du flake

| Input | Source |
|---|---|
| **nixpkgs** | `nixos-unstable` |
| **home-manager** | `nix-community/home-manager` (suit nixpkgs) |
| **NUR** | `nix-community/NUR` (suit nixpkgs) |

## Host : `furnace`

Machine de bureau Intel + NVIDIA sous KDE Plasma 6 / Wayland.

- **Boot** : systemd-boot, kernel latest, module `atlantic`
- **GPU** : NVIDIA (driver beta, open kernel module, modesetting)
- **Desktop** : KDE Plasma 6 + SDDM Wayland
- **Audio** : PipeWire (ALSA, PulseAudio, JACK)
- **Gaming** : Steam, Proton, MangoHud, Gamemode, Wine
- **Shell** : Zsh (autosuggestion, syntax highlighting, prompt custom) + Kitty
- **Apps** : 1Password, IntelliJ IDEA, Brave (policies hardening), Discord, Zulip, Element
- **VCS** : Jujutsu (avec identité configurée), Git
- **SSH** : Agent 1Password (`~/.1password/agent.sock`)
- **Locale** : `fr_FR.UTF-8`, clavier FR

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
4. Rebuild : `sudo nixos-rebuild switch --flake .#<nom>`
