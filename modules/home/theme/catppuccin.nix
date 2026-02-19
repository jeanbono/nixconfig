{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.theme.catppuccin;

  hexToRgba = hex: alpha:
    let
      h = builtins.substring 1 6 hex;
      r = lib.fromHexString (builtins.substring 0 2 h);
      g = lib.fromHexString (builtins.substring 2 2 h);
      b = lib.fromHexString (builtins.substring 4 2 h);
    in "rgba(${toString r}, ${toString g}, ${toString b}, ${toString alpha})";
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

    waybarSource = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "waybar";
        rev = "v1.1";
        sha256 = "sha256-9lY+v1CTbpw2lREG/h65mLLw5KuT8OJdEPOb+NNC6Fo=";
      };
      description = "Source du thème Catppuccin pour Waybar";
    };

    dunstSource = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "dunst";
        rev = "main";
        sha256 = "sha256-rBp9wU6QHpmNAjeaKnI6u8rOUlv8MC70SLUzeKHN/eY=";
      };
      description = "Source du thème Catppuccin pour Dunst";
    };

    dunstThemeFile = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "${cfg.dunstSource}/themes/${cfg.flavor}.conf";
      description = "Chemin vers le fichier de thème Dunst";
    };

    # Chemins calculés
    hyprlandThemeFile = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "${cfg.hyprlandSource}/themes/${cfg.flavor}.conf";
      description = "Chemin vers le fichier de thème Hyprland";
    };

    waybarThemeFile = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "${cfg.waybarSource}/themes/${cfg.flavor}.css";
      description = "Chemin vers le fichier CSS Waybar";
    };

    # Fonction rgba(couleur, alpha) pour les couleurs avec transparence
    rgba = lib.mkOption {
      type = lib.types.functionTo (lib.types.functionTo lib.types.str);
      readOnly = true;
      default = hex: alpha: hexToRgba hex alpha;
      description = "Convertit une couleur hex de la palette en rgba(r,g,b,alpha)";
    };

    # Palette de couleurs hex selon le flavor
    palette = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      readOnly = true;
      default =
        let
          palettes = {
            mocha = {
              base    = "#1e1e2e"; mantle  = "#181825"; crust   = "#11111b";
              surface0= "#313244"; surface1= "#45475a"; surface2= "#585b70";
              overlay0= "#6c7086"; overlay1= "#7f849c"; overlay2= "#9399b2";
              subtext0= "#a6adc8"; subtext1= "#bac2de";
              text    = "#cdd6f4";
              rosewater="#f5e0dc"; flamingo= "#f2cdcd"; pink    = "#f38ba8";
              mauve   = "#cba6f7"; red     = "#f38ba8"; maroon  = "#eba0ac";
              peach   = "#fab387"; yellow  = "#f9e2af"; green   = "#a6e3a1";
              teal    = "#94e2d5"; sky     = "#89dceb"; sapphire= "#74c7ec";
              blue    = "#89b4fa"; lavender= "#b4befe";
            };
            macchiato = {
              base    = "#24273a"; mantle  = "#1e2030"; crust   = "#181926";
              surface0= "#363a4f"; surface1= "#494d64"; surface2= "#5b6078";
              overlay0= "#6e738d"; overlay1= "#8087a2"; overlay2= "#939ab7";
              subtext0= "#a5adcb"; subtext1= "#b8c0e0";
              text    = "#cad3f5";
              rosewater="#f4dbd6"; flamingo= "#f0c6c6"; pink    = "#f5bde6";
              mauve   = "#c6a0f6"; red     = "#ed8796"; maroon  = "#ee99a0";
              peach   = "#f5a97f"; yellow  = "#eed49f"; green   = "#a6da95";
              teal    = "#8bd5ca"; sky     = "#91d7e3"; sapphire= "#7dc4e4";
              blue    = "#8aadf4"; lavender= "#b7bdf8";
            };
            frappe = {
              base    = "#303446"; mantle  = "#292c3c"; crust   = "#232634";
              surface0= "#414559"; surface1= "#51576d"; surface2= "#626880";
              overlay0= "#737994"; overlay1= "#838ba7"; overlay2= "#949cbb";
              subtext0= "#a5adce"; subtext1= "#b5bfe2";
              text    = "#c6d0f5";
              rosewater="#f2d5cf"; flamingo= "#eebebe"; pink    = "#f4b8e4";
              mauve   = "#ca9ee6"; red     = "#e78284"; maroon  = "#ea999c";
              peach   = "#ef9f76"; yellow  = "#e5c890"; green   = "#a6d189";
              teal    = "#81c8be"; sky     = "#99d1db"; sapphire= "#85c1dc";
              blue    = "#8caaee"; lavender= "#babbf1";
            };
            latte = {
              base    = "#eff1f5"; mantle  = "#e6e9ef"; crust   = "#dce0e8";
              surface0= "#ccd0da"; surface1= "#bcc0cc"; surface2= "#acb0be";
              overlay0= "#9ca0b0"; overlay1= "#8c8fa1"; overlay2= "#7c7f93";
              subtext0= "#6c6f85"; subtext1= "#5c5f77";
              text    = "#4c4f69";
              rosewater="#dc8a78"; flamingo= "#dd7878"; pink    = "#ea76cb";
              mauve   = "#8839ef"; red     = "#d20f39"; maroon  = "#e64553";
              peach   = "#fe640b"; yellow  = "#df8e1d"; green   = "#40a02b";
              teal    = "#179299"; sky     = "#04a5e5"; sapphire= "#209fb5";
              blue    = "#1e66f5"; lavender= "#7287fd";
            };
          };
        in
        palettes.${cfg.flavor};
      description = "Palette de couleurs hex Catppuccin pour le flavor choisi";
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
