{ pkgs, lib, config, ... }:

let
  cfg = config.modules.plasma;
  hyprlandCfg = config.modules.hyprland;
in
{
  options.modules.plasma.enable = lib.mkEnableOption "KDE Plasma 6 + SDDM Wayland + polices";

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = !hyprlandCfg.enable;
      message = "modules.plasma et modules.hyprland sont mutuellement exclusifs";
    }];

    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

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
        rgba = "none";
        lcdfilter = "default";
      };
    };

    home-manager.users = lib.genAttrs config.modules.users (_: {
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
    });
  };
}
