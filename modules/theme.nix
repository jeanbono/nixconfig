{ pkgs, lib, config, ... }:

let
  cap = s:
    lib.strings.toUpper (builtins.substring 0 1 s)
    + builtins.substring 1 (builtins.stringLength s - 1) s;

  hyprlandSource = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "hyprland";
    rev = "v1.3";
    sha256 = "sha256-xSa/z0Pu+ioZ0gFH9qSo9P94NPkEMovstm1avJ7rvzM=";
  };

  alacrittySource = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "alacritty";
    rev = "f6cb5a5c2b404cdaceaff193b9c52317f62c62f7";
    sha256 = "1r2z223hza63v5lmzlg3022mlar67j3a2gh41rsaiqwja2wyiihz";
  };

  # Raccourci évalué après que flavor/accent soient résolus
  cfg = config.modules.theme.catppuccin;
in
{
  options.modules.theme.catppuccin = {
    enable = lib.mkEnableOption "Thème Catppuccin";

    flavor = lib.mkOption {
      type = lib.types.enum [ "latte" "frappe" "macchiato" "mocha" ];
      default = "macchiato";
      description = "Variante Catppuccin";
    };

    accent = lib.mkOption {
      type = lib.types.enum [
        "rosewater" "flamingo" "pink" "mauve" "red" "maroon"
        "peach" "yellow" "green" "teal" "sky" "sapphire" "blue" "lavender"
      ];
      default = "blue";
      description = "Couleur d'accent Catppuccin";
    };

    # Options dérivées : calculées dans config pour éviter la récursivité
    hyprlandThemeFile = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Chemin vers le thème Hyprland Catppuccin";
    };

    alacrittyThemeFile = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Chemin vers le thème Alacritty Catppuccin";
    };

    gtkThemeName = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Nom du thème GTK Catppuccin";
    };
  };

  config = lib.mkIf cfg.enable {
    modules.theme.catppuccin.hyprlandThemeFile =
      "${hyprlandSource}/themes/${cfg.flavor}.conf";
    modules.theme.catppuccin.alacrittyThemeFile =
      "${alacrittySource}/catppuccin-${cfg.flavor}.toml";
    modules.theme.catppuccin.gtkThemeName =
      "Catppuccin-${cap cfg.flavor}-Standard-${cap cfg.accent}-Dark";

    home-manager.users = lib.genAttrs config.modules.users (_: {
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
    });
  };
}
