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
    ├── system/                # Modules NixOS (auto-discovery, structure plate)
    │   ├── nix.nix            #   modules.system.nix
    │   ├── locale.nix         #   modules.system.locale
    │   ├── network.nix        #   modules.system.network
    │   ├── audio.nix          #   modules.system.audio
    │   ├── printing.nix       #   modules.system.printing
    │   ├── plasma.nix         #   modules.system.plasma
    │   ├── nvidia.nix         #   modules.system.nvidia
    │   ├── gaming.nix         #   modules.system.gaming
    │   ├── onepassword.nix    #   modules.system.onepassword
    │   ├── shell.nix          #   modules.system.shell
    │   ├── dev.nix            #   modules.system.dev
    │   └── home-manager.nix   #   Intégration Home Manager (toujours actif)
    └── home/                  # Modules Home Manager (auto-discovery, structure plate)
        ├── shell.nix          #   modules.home.shell
        ├── git.nix            #   modules.home.git
        ├── ssh.nix            #   modules.home.ssh
        ├── brave.nix          #   modules.home.brave
        ├── messaging.nix      #   modules.home.messaging
        ├── desktop.nix        #   modules.home.desktop
        ├── dev.nix            #   modules.home.dev
        └── onepassword.nix    #   modules.home.onepassword
```

## Modules disponibles

### Système (`modules.system.*`)

| Option | Description |
|---|---|
| `modules.system.nix.enable` | Flakes, auto-optimise-store, GC hebdomadaire |
| `modules.system.locale.enable` | Locale `fr_FR.UTF-8`, clavier français |
| `modules.system.network.enable` | NetworkManager, SSH, curl, wget |
| `modules.system.audio.enable` | PipeWire (ALSA, PulseAudio, JACK) |
| `modules.system.printing.enable` | Impression (CUPS) |
| `modules.system.plasma.enable` | KDE Plasma 6 + SDDM Wayland + polices |
| `modules.system.nvidia.enable` | Pilote NVIDIA beta, open kernel module, modesetting |
| `modules.system.gaming.enable` | Steam, Proton, MangoHud, Gamemode, Wine |
| `modules.system.onepassword.enable` | 1Password CLI + GUI |
| `modules.system.shell.enable` | Zsh (niveau système) |
| `modules.system.dev.enable` | Environnement de développement (Java) |

### Home Manager (`modules.home.*`)

| Option | Description |
|---|---|
| `modules.home.shell.enable` | Zsh (autosuggestion, prompt custom) + Kitty |
| `modules.home.git.enable` | Git + Jujutsu (identité configurée) |
| `modules.home.ssh.enable` | SSH + agent 1Password |
| `modules.home.brave.enable` | Brave browser + policies hardening |
| `modules.home.messaging.enable` | Discord, Zulip, Element |
| `modules.home.desktop.enable` | Paquets CLI (ripgrep, fd, jq…), variables Wayland |
| `modules.home.dev.enable` | Outils de développement (IntelliJ IDEA) |
| `modules.home.onepassword.enable` | Extension 1Password pour Brave (requiert modules.home.brave) |

## Inputs du flake

| Input | Source |
|---|---|
| **nixpkgs** | `nixos-unstable` |
| **home-manager** | `nix-community/home-manager` (suit nixpkgs) |
| **NUR** | `nix-community/NUR` (suit nixpkgs) |

## Host : `furnace`

Machine de bureau Intel + NVIDIA sous KDE Plasma 6 / Wayland.

```nix
# hosts/furnace/default.nix
modules.system = {
  nix.enable = true;
  locale.enable = true;
  network.enable = true;
  audio.enable = true;
  printing.enable = true;
  plasma.enable = true;
  nvidia.enable = true;
  gaming.enable = true;
  onepassword.enable = true;
  shell.enable = true;
  dev.enable = true;
};
```

```nix
# home/furnace/pierre.nix
modules.home = {
  shell.enable = true;
  git.enable = true;
  ssh.enable = true;
  brave.enable = true;
  messaging.enable = true;
  desktop.enable = true;
  dev.enable = true;
  onepassword.enable = true;
};
```

- **Boot** : systemd-boot, kernel latest, module `atlantic`

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

Il suffit de créer un fichier `.nix` dans `modules/system/` ou `modules/home/`.
Le module sera automatiquement importé grâce à `lib.nix`. Il ne reste qu'à l'activer dans le host avec `modules.<system|home>.<nom>.enable = true;`.

### Exemple : serveur headless

```nix
# Seulement le strict nécessaire, pas d'audio/plasma/gaming
modules.system = {
  nix.enable = true;
  locale.enable = true;
  network.enable = true;
};
```
