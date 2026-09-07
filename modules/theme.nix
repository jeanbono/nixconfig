let
  flavor = "macchiato";

  # Ghostty bundles Catppuccin themes under their display names rather than
  # the lowercase flavor slugs used elsewhere (e.g. "Catppuccin Macchiato").
  ghosttyThemeNames = {
    latte = "Catppuccin Latte";
    frappe = "Catppuccin Frappe";
    macchiato = "Catppuccin Macchiato";
    mocha = "Catppuccin Mocha";
  };
in
{
  flake.lib.theme = {
    inherit flavor;
    ghosttyTheme = ghosttyThemeNames.${flavor};
  };

  den.aspects.theme.homeManager = { pkgs, ... }: {
    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    gtk = {
      enable = true;
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
      papirus-icon-theme
    ];
  };
}
