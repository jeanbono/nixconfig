{ pkgs, lib, config, ... }:

let
  cfg = config.modules.system.plasma;
in
{
  options.modules.system.plasma.enable = lib.mkEnableOption "KDE Plasma 6 + SDDM Wayland";

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm.enable = true;
    # Sur versions récentes, SDDM peut tourner en Wayland
    services.displayManager.sddm.wayland.enable = true;

    services.desktopManager.plasma6.enable = true;

    # Qualité de vie Wayland (Electron/Chromium)
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
