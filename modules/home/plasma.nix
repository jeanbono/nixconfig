{ lib, config, ... }:

let
  cfg = config.modules.home.plasma;
in
{
  options.modules.home.plasma.enable = lib.mkEnableOption "Configuration Plasma (panels, layout)";

  config = lib.mkIf cfg.enable {
    # Variables utiles Wayland / Electron (côté user)
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    programs.plasma.panels = [
      # Top bar : menu | spacer | system tray | horloge
      {
        location = "top";
        height = 32;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.panelspacer"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
      # Dock en bas : icon-only task manager (apps)
      {
        location = "bottom";
        height = 56;
        floating = true;
        lengthMode = "fit";
        widgets = [
          "org.kde.plasma.icontasks"
        ];
      }
    ];
  };
}
