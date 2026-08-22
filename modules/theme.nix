let
  flavor = "macchiato";
in
{
  flake.lib.theme = {
    inherit flavor;

    alacrittyThemeFile = { pkgs }:
      let
        alacrittySource = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "alacritty";
          rev = "f6cb5a5c2b404cdaceaff193b9c52317f62c62f7";
          sha256 = "1r2z223hza63v5lmzlg3022mlar67j3a2gh41rsaiqwja2wyiihz";
        };
      in
      "${alacrittySource}/catppuccin-${flavor}.toml";
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
