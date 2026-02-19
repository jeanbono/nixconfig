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

          modules-left = [ "hyprland/window" ];
          modules-center = [ "hyprland/workspaces" ];
          modules-right = [ "tray" "pulseaudio" "network" "clock" ];

          "hyprland/workspaces" = {
            format = "●";
            persistent-workspaces = {
              "DP-1" = [ 1 2 3 4 5 ];
              "DP-3" = [ 6 7 8 9 10 ];
            };
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
          };

          "hyprland/window" = {
            format = "  {}";
            max-length = 60;
            separate-outputs = true;
          };

          clock = {
            format = "  {:%H:%M}";
            format-alt = "  {:%A %d %B %Y}";
            tooltip-format = "<tt>{calendar}</tt>";
            calendar = {
              mode = "month";
              on-scroll = 1;
              format = {
                today = "<span color='#cba6f7'><b><u>{}</u></b></span>";
              };
            };
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "󰝟 muet";
            format-icons = {
              default = [ "󰕿" "󰖀" "󰕾" ];
              headphone = "󰋋";
              headset = "󰋎";
            };
            on-click = "pavucontrol";
            on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +2%";
            on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -2%";
            tooltip-format = "{desc} — {volume}%";
          };

          network = {
            format-wifi = "󰤨 {essid}";
            format-ethernet = "󰈀 {ifname}";
            format-disconnected = "󰤭";
            tooltip-format-wifi = "{essid} ({signalStrength}%) — {ipaddr}";
            tooltip-format-ethernet = "{ifname}: {ipaddr}/{cidr}";
            tooltip-format-disconnected = "Déconnecté";
            on-click = "kitty -e nmtui";
          };

          tray = {
            icon-size = 16;
            spacing = 6;
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
          border: none;
          border-radius: 0;
        }

        window#waybar {
          background-color: alpha(@base, 0.90);
          color: @text;
          border-bottom: 1px solid alpha(@surface1, 0.5);
        }

        /* ── Fenêtre active ─────────────────────────────── */
        #window {
          color: @subtext1;
          padding: 0 12px;
          font-style: italic;
        }


        /* ── Workspaces ─────────────────────────────────── */
        #workspaces {
          margin: 4px 0;
          padding: 0 4px;
        }

        #workspaces button {
          padding: 0 3px;
          color: alpha(@overlay1, 0.5);
          margin: 0;
          transition: color 0.15s ease;
          font-size: 10px;
          background: transparent;
          box-shadow: none;
        }

        #workspaces button.active {
          color: @mauve;
          font-size: 14px;
        }

        #workspaces button.occupied {
          color: @overlay2;
        }

        #workspaces button.urgent {
          color: @red;
          font-size: 14px;
        }

        #workspaces button:hover {
          color: @text;
          background: transparent;
          box-shadow: none;
        }

        /* ── Modules droite ─────────────────────────────── */
        #pulseaudio, #network, #clock {
          padding: 0 12px;
          color: @text;
        }

        #pulseaudio {
          color: @pink;
        }

        #pulseaudio.muted {
          color: @overlay0;
        }

        #network {
          color: @sky;
        }

        #network.disconnected {
          color: @red;
        }

        #clock {
          color: @lavender;
          font-weight: bold;
        }

        #tray {
          padding: 0 8px;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: alpha(@red, 0.2);
          border-radius: 4px;
        }
      '';
    };
  };
}
