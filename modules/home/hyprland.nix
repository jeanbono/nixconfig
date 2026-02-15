{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
  plasmaCfg = config.modules.home.plasma;
in
{
  options.modules.home.hyprland.enable = lib.mkEnableOption "Configuration Hyprland (compositor, waybar, keybinds)";

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = !plasmaCfg.enable;
      message = "modules.home.hyprland et modules.home.plasma sont mutuellement exclusifs";
    }];

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    xdg.configFile."hypr/hyprland.conf".force = true;

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;

      settings = {
        # ── Moniteur ──────────────────────────────────────────────
        monitor = [
          "DP-3, 2560x1440@165, 0x0, 1, bitdepth, 10, cm, hdr"
          "DP-1, 2560x1440@300, 2560x0, 1, bitdepth, 10, cm, hdr"
        ];

        # ── Entrée ────────────────────────────────────────────────
        input = {
          kb_layout = "fr";
          follow_mouse = 1;
          sensitivity = 0;
        };

        # ── Apparence ─────────────────────────────────────────────
        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          "col.active_border" = "rgba(89b4faee) rgba(cba6f7ee) 45deg";
          "col.inactive_border" = "rgba(313244aa)";
          layout = "dwindle";
        };

        decoration = {
          rounding = 8;
          blur = {
            enabled = true;
            size = 6;
            passes = 2;
          };
          shadow = {
            enabled = true;
            range = 12;
            render_power = 3;
            color = "rgba(1a1a2eee)";
          };
        };

        animations = {
          enabled = true;
          bezier = [ "ease, 0.25, 0.1, 0.25, 1" ];
          animation = [
            "windows, 1, 4, ease"
            "windowsOut, 1, 4, ease, popin 80%"
            "fade, 1, 4, ease"
            "workspaces, 1, 3, ease"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
        };

        # ── Nvidia ────────────────────────────────────────────────
        env = [
          "LIBVA_DRIVER_NAME,nvidia"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          "ELECTRON_OZONE_PLATFORM_HINT,auto"
          "NVD_BACKEND,direct"
        ];

        cursor = {
          no_hardware_cursors = true;
        };

        # ── Autostart ─────────────────────────────────────────────
        exec-once = [
          "hyprlock"
          "waybar"
          "hypridle"
        ];

        # ── Raccourcis clavier ────────────────────────────────────
        "$mod" = "SUPER";

        bind = [
          "$mod, Escape, exec, hyprlock"
          "$mod, Return, exec, kitty"
          "$mod, Q, killactive"
          "$mod, M, exit"
          "$mod, E, exec, thunar"
          "$mod, V, togglefloating"
          "$mod, D, exec, wofi --show drun"
          "$mod, F, fullscreen"
          "$mod, P, pseudo"
          "$mod, S, togglesplit"

          # Déplacement du focus
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"

          # Workspaces
          "$mod, ampersand, workspace, 1"
          "$mod, eacute, workspace, 2"
          "$mod, quotedbl, workspace, 3"
          "$mod, apostrophe, workspace, 4"
          "$mod, parenleft, workspace, 5"
          "$mod, minus, workspace, 6"
          "$mod, egrave, workspace, 7"
          "$mod, underscore, workspace, 8"
          "$mod, ccedilla, workspace, 9"
          "$mod, agrave, workspace, 10"

          # Déplacer fenêtre vers workspace
          "$mod SHIFT, ampersand, movetoworkspace, 1"
          "$mod SHIFT, eacute, movetoworkspace, 2"
          "$mod SHIFT, quotedbl, movetoworkspace, 3"
          "$mod SHIFT, apostrophe, movetoworkspace, 4"
          "$mod SHIFT, parenleft, movetoworkspace, 5"
          "$mod SHIFT, minus, movetoworkspace, 6"
          "$mod SHIFT, egrave, movetoworkspace, 7"
          "$mod SHIFT, underscore, movetoworkspace, 8"
          "$mod SHIFT, ccedilla, movetoworkspace, 9"
          "$mod SHIFT, agrave, movetoworkspace, 10"

          # Scroll workspaces
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"
        ];

        # Déplacement / redimensionnement souris
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };
    };

    # ── Waybar ──────────────────────────────────────────────────
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
        * {
          font-family: "FiraCode Nerd Font", "Noto Sans", sans-serif;
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background: rgba(30, 30, 46, 0.85);
          color: #cdd6f4;
          border-bottom: 2px solid rgba(137, 180, 250, 0.3);
        }

        #workspaces button {
          padding: 0 6px;
          color: #6c7086;
          border: none;
          border-radius: 4px;
          margin: 3px 2px;
        }

        #workspaces button.active {
          color: #cdd6f4;
          background: rgba(137, 180, 250, 0.25);
        }

        #workspaces button:hover {
          background: rgba(137, 180, 250, 0.15);
        }

        #clock, #cpu, #memory, #pulseaudio, #network, #tray {
          padding: 0 10px;
        }

        #clock {
          font-weight: bold;
          color: #89b4fa;
        }

        #cpu { color: #a6e3a1; }
        #memory { color: #f9e2af; }

        #pulseaudio { color: #f5c2e7; }
        #pulseaudio.muted { color: #6c7086; }

        #network { color: #89dceb; }
        #network.disconnected { color: #f38ba8; }

        #tray { padding: 0 6px; }
      '';
    };

    # ── Wofi (lanceur d'applications) ───────────────────────────
    xdg.configFile."wofi/style.css".text = ''
      window {
        margin: 0;
        border: 2px solid rgba(137, 180, 250, 0.4);
        border-radius: 12px;
        background-color: rgba(30, 30, 46, 0.92);
        font-family: "FiraCode Nerd Font", "Noto Sans", sans-serif;
        font-size: 14px;
      }

      #input {
        margin: 8px;
        padding: 8px 12px;
        border: none;
        border-radius: 8px;
        background-color: rgba(49, 50, 68, 0.9);
        color: #cdd6f4;
      }

      #input:focus {
        border: 2px solid rgba(137, 180, 250, 0.5);
      }

      #inner-box {
        margin: 0 8px 8px 8px;
      }

      #outer-box {
        margin: 0;
        padding: 0;
      }

      #entry {
        padding: 6px 12px;
        border-radius: 8px;
        color: #cdd6f4;
      }

      #entry:selected {
        background-color: rgba(137, 180, 250, 0.2);
        color: #cdd6f4;
      }

      #entry:hover {
        background-color: rgba(137, 180, 250, 0.1);
      }

      #text {
        color: #cdd6f4;
      }

      #text:selected {
        color: #cdd6f4;
      }
    '';

    xdg.configFile."wofi/config".text = ''
      width=500
      height=350
      show=drun
      prompt=Rechercher...
      allow_markup=true
      insensitive=true
      columns=1
      hide_scroll=true
      matching=fuzzy
      sort_order=alphabetical
    '';

    # ── Hyprlock (écran de verrouillage) ────────────────────────
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
          grace = 5;
        };

        background = [{
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }];

        input-field = [{
          size = "250, 50";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.15;
          outer_color = "rgba(137, 180, 250, 0.5)";
          inner_color = "rgba(30, 30, 46, 0.9)";
          font_color = "rgb(205, 214, 244)";
          fade_on_empty = false;
          placeholder_text = "Mot de passe...";
          fail_text = "Incorrect";
          halign = "center";
          valign = "center";
        }];

        label = [{
          text = "cmd[update:1000] date +\"%H:%M\"";
          color = "rgba(205, 214, 244, 1.0)";
          font_size = 64;
          font_family = "FiraCode Nerd Font";
          position = "0, 120";
          halign = "center";
          valign = "center";
        }];
      };
    };

    # ── Hypridle (verrouillage automatique) ───────────────────
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "hyprlock";
            on-resume = "";
          }
          {
            timeout = 600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    # ── Paquets complémentaires ─────────────────────────────────
    home.packages = with pkgs; [
      hypridle      # Verrouillage automatique après inactivité
      thunar        # Explorateur de fichiers
      gvfs          # Support montage/corbeille dans Thunar
      wofi          # Lanceur d'applications
      wl-clipboard  # Copier/coller Wayland
      grim          # Capture d'écran
      slurp         # Sélection de zone
      swww          # Fond d'écran animé
      pavucontrol   # Contrôle audio
      brightnessctl # Luminosité
      dunst         # Notifications
    ];
  };
}
