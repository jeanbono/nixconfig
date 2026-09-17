{ lib, inputs, ... }:
let
  flavor = "macchiato";
  accent = "mauve";
  title = s: lib.toUpper (builtins.substring 0 1 s) + builtins.substring 1 (-1) s;
  theme = {
    inherit flavor accent;
    # Noctalia community palette with the same flavor and accent.
    name = "Catppuccin ${title flavor} ${title accent}";
    font = "MonaspiceNe Nerd Font";
  };
in
{
  flake.lib.theme = theme;

  den.aspects.theme.homeManager =
    { config, pkgs, ... }:
    {
      imports = [ inputs.catppuccin.homeModules.catppuccin ];

      # Themes every supported program enabled through Home Manager.
      catppuccin = {
        enable = true;
        autoEnable = true;
        inherit flavor accent;
        # A neutral pointer, independent of the application accent.
        cursors = {
          enable = true;
          accent = "light";
        };
        # qtct palettes; Kvantum would replace the Fusion style.
        qt5ct.enable = true;
        kvantum.enable = false;
      };

      dconf.settings."org/gnome/desktop/interface".accent-color = "purple";
      home.pointerCursor = {
        enable = true;
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };
      gtk = {
        enable = true;
        colorScheme = "dark";
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        # Colors rendered by Noctalia's GTK templates. Declaring the import
        # keeps its hook from replacing the Home Manager-managed gtk.css.
        gtk3.extraCss = ''@import url("noctalia.css");'';
        gtk4.theme = null;
        gtk4.extraCss = ''@import url("noctalia.css");'';
        font = {
          name = theme.font;
          size = 11;
        };
      };
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "Fusion";
        qt5ctSettings.Appearance.icon_theme = config.gtk.iconTheme.name;
        qt6ctSettings.Appearance.icon_theme = config.gtk.iconTheme.name;
      };
    };
}
