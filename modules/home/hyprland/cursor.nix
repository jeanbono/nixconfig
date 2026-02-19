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
    home.file.".local/share/icons/rose-pine-hyprcursor".source = rose-pine-hyprcursor;

    gtk.cursorTheme = {
      name = "rose-pine-hyprcursor";
      package = rose-pine-hyprcursor;
    };
  };
}
