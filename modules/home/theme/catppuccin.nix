{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.theme.catppuccin;
in
{
  options.modules.home.theme.catppuccin = {
    enable = lib.mkEnableOption "Thème Catppuccin";

    flavor = lib.mkOption {
      type = lib.types.enum [ "latte" "frappe" "macchiato" "mocha" ];
      default = "macchiato";
      description = "Variante Catppuccin à utiliser";
    };

    accent = lib.mkOption {
      type = lib.types.enum [
        "rosewater" "flamingo" "pink" "mauve" "red" "maroon"
        "peach" "yellow" "green" "teal" "sky" "sapphire" "blue" "lavender"
      ];
      default = "blue";
      description = "Couleur d'accent Catppuccin";
    };

    # Sources dérivées (lecture seule, calculées depuis flavor)
    hyprlandSource = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "hyprland";
        rev = "v1.3";
        sha256 = "sha256-xSa/z0Pu+ioZ0gFH9qSo9P94NPkEMovstm1avJ7rvzM=";
      };
      description = "Source du thème Catppuccin pour Hyprland";
    };

    wlogoutSource = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "wlogout";
        rev = "main";
        sha256 = "sha256-0VCk+7t/cSEmcnfvKdxUDwwrtK0VLhZrVpw4enoBEbc=";
      };
      description = "Source du thème Catppuccin pour wlogout";
    };

    wlogoutThemeFile = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "${cfg.wlogoutSource}/themes/${cfg.flavor}/${cfg.accent}.css";
      description = "Chemin vers le fichier CSS wlogout";
    };

    wlogoutIconsDir = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "${cfg.wlogoutSource}/icons/wlogout/${cfg.flavor}/${cfg.accent}";
      description = "Chemin vers les icônes SVG wlogout";
    };

    alacrittySource = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "alacritty";
        rev = "f6cb5a5c2b404cdaceaff193b9c52317f62c62f7";
        sha256 = "1r2z223hza63v5lmzlg3022mlar67j3a2gh41rsaiqwja2wyiihz";
      };
      description = "Source du thème Catppuccin pour Alacritty";
    };

    alacrittyThemeFile = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "${cfg.alacrittySource}/catppuccin-${cfg.flavor}.toml";
      description = "Chemin vers le fichier de thème Alacritty";
    };

    # Chemins calculés
    hyprlandThemeFile = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "${cfg.hyprlandSource}/themes/${cfg.flavor}.conf";
      description = "Chemin vers le fichier de thème Hyprland";
    };

    # Nom du thème GTK complet
    gtkThemeName = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default =
        let
          flavorCap = lib.strings.toUpper (builtins.substring 0 1 cfg.flavor)
            + builtins.substring 1 (builtins.stringLength cfg.flavor - 1) cfg.flavor;
          accentCap = lib.strings.toUpper (builtins.substring 0 1 cfg.accent)
            + builtins.substring 1 (builtins.stringLength cfg.accent - 1) cfg.accent;
        in
        "Catppuccin-${flavorCap}-Standard-${accentCap}-Dark";
      description = "Nom du thème GTK Catppuccin";
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      GTK_THEME = cfg.gtkThemeName;
    };

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    gtk = {
      enable = true;
      theme = {
        name = cfg.gtkThemeName;
        package = pkgs.catppuccin-gtk;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      font = {
        name = "MonaspiceNe Nerd Font";
        size = 11;
      };
    };

    home.packages = with pkgs; [
      catppuccin-gtk
      papirus-icon-theme
    ];
  };
}
