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

    programs.plasma = {
      enable = true;
      overrideConfig = true;

      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        colorScheme = "BreezeDark";
        theme = "breeze-dark";
      };

      kwin.effects.blur.enable = true;

      panels = [
        # Top bar : menu | spacer | system tray | horloge
        {
          location = "top";
          screen = 0;
          height = 32;
          widgets = [
            "org.kde.plasma.kickoff"
            "org.kde.plasma.appmenu"
            "org.kde.plasma.panelspacer"
            "org.kde.plasma.systemtray"
            "org.kde.plasma.digitalclock"
          ];
        }
        # Dock en bas : style macOS
        {
          location = "bottom";
          screen = 0;
          height = 48;
          floating = true;
          lengthMode = "fit";
          alignment = "center";
          hiding = "dodgewindows";
          opacity = "translucent";
          widgets = [
            {
              name = "org.kde.plasma.icontasks";
              config = {
                General = {
                  fill = false;
                  iconSpacing = 4;
                  indicateAudioStreams = false;
                  highlightWindows = false;
                };
              };
            }
          ];
        }
      ];
    };
  };
}
