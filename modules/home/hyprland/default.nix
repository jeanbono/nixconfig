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
    ./yazi.nix
    ./packages.nix
  ];

  options.modules.home.hyprland.enable = lib.mkEnableOption "Configuration Hyprland (compositor, caelestia, keybinds)";

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
