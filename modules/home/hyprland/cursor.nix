{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.hyprland;

  rose-pine-hyprcursor = pkgs.fetchFromGitHub {
    owner = "ndom91";
    repo = "rose-pine-hyprcursor";
    rev = "main";
    sha256 = "sha256-ouuA8LVBXzrbYwPW2vNjh7fC9H2UBud/1tUiIM5vPvM=";
  };
in
{
  config = lib.mkIf cfg.enable {
    # Hyprcursor (format moderne pour Hyprland)
    home.file.".local/share/icons/rose-pine-hyprcursor".source = rose-pine-hyprcursor;

    home.sessionVariables = {
      HYPRCURSOR_THEME = "rose-pine-hyprcursor";
      HYPRCURSOR_SIZE = "24";
    };

    # Xcursor classique (fallback pour GTK/X11)
    gtk.cursorTheme = {
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-cursor;
      size = 24;
    };

    home.packages = [ pkgs.rose-pine-cursor ];
  };
}
