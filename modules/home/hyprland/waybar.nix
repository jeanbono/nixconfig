{ lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
  themeCfg = config.modules.home.theme.catppuccin;
in
{
  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 34;
          spacing = 8;

          modules-left = [ "hyprland/workspaces" "hyprland/window" ];
          modules-center = [ "clock" ];
          modules-right = [ "pulseaudio" "network" "cpu" "memory" "tray" ];

          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              active = "";
              default = "";
              empty = "";
            };
            persistent-workspaces = {
              "*" = 5;
            };
          };

          "hyprland/window" = {
            max-length = 50;
          };

          clock = {
            format = "{:%H:%M}";
            format-alt = "{:%A %d %B %Y, %H:%M}";
            tooltip-format = "<tt>{calendar}</tt>";
          };

          cpu = {
            format = " {usage}%";
            interval = 2;
          };

          memory = {
            format = " {percentage}%";
            interval = 2;
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = " muet";
            format-icons = {
              default = [ "" "" "" ];
            };
            on-click = "pavucontrol";
          };

          network = {
            format-wifi = " {signalStrength}%";
            format-ethernet = " {ipaddr}";
            format-disconnected = "⚠ déconnecté";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          };

          tray = {
            icon-size = 18;
            spacing = 8;
            show-passive-items = true;
          };
        };
      };

      style = ''
        @import "${themeCfg.waybarThemeFile}";

        * {
          font-family: "MonaspiceNe Nerd Font", "Noto Sans", sans-serif;
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background-color: alpha(@base, 0.85);
          color: @text;
          border-bottom: 2px solid alpha(@mauve, 0.3);
        }

        #workspaces button {
          padding: 0 6px;
          color: @subtext0;
          border: none;
          border-radius: 4px;
          margin: 3px 2px;
        }

        #workspaces button.active {
          color: @text;
          background-color: alpha(@mauve, 0.25);
        }

        #workspaces button:hover {
          background-color: alpha(@mauve, 0.15);
        }

        #clock, #cpu, #memory, #pulseaudio, #network, #tray {
          padding: 0 10px;
        }

        #clock {
          font-weight: bold;
          color: @blue;
        }

        #cpu { color: @green; }
        #memory { color: @yellow; }

        #pulseaudio { color: @pink; }
        #pulseaudio.muted { color: @subtext0; }

        #network { color: @sky; }
        #network.disconnected { color: @red; }

        #tray { padding: 0 6px; }
      '';
    };
  };
}
