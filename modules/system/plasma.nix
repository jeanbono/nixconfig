{ pkgs, lib, config, ... }:

let
  cfg = config.modules.system.plasma;
  hyprlandCfg = config.modules.system.hyprland;
in
{
  options.modules.system.plasma.enable = lib.mkEnableOption "KDE Plasma 6 + SDDM Wayland + polices";

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = !hyprlandCfg.enable;
      message = "modules.system.plasma et modules.system.hyprland sont mutuellement exclusifs";
    }];
    services.displayManager.sddm.enable = true;
    # Sur versions récentes, SDDM peut tourner en Wayland
    services.displayManager.sddm.wayland.enable = true;

    services.desktopManager.plasma6.enable = true;

    # Qualité de vie Wayland (Electron/Chromium)
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    fonts.packages = with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.fira-code
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    fonts.fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "none";      # IMPORTANT pour Wayland
        lcdfilter = "default";
      };
    };
  };
}
