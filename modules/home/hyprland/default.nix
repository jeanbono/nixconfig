{ lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
  plasmaCfg = config.modules.home.plasma;
in
{
  imports = [
    ./core.nix
    ./cursor.nix
    ./scripts.nix
    ./waybar.nix
    ./wofi.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./dunst.nix
    ./hyprpaper.nix
    ./packages.nix
  ];

  options.modules.home.hyprland.enable = lib.mkEnableOption "Configuration Hyprland (compositor, waybar, keybinds)";

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = !plasmaCfg.enable;
      message = "modules.home.hyprland et modules.home.plasma sont mutuellement exclusifs";
    }];

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
