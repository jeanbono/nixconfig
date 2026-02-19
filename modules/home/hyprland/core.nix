{ lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
  themeCfg = config.modules.home.theme.catppuccin;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."hypr/hyprland.conf".force = true;

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;

      settings = {
        # ── Moniteur ──────────────────────────────────────────────
        monitor = [
          "DP-3, 2560x1440@165, 0x0, 1, bitdepth, 10, cm, hdr, sdrbrightness, 1.3"
          "DP-1, 2560x1440@300, 2560x0, 1, bitdepth, 10, cm, hdr, sdrbrightness, 1.3"
        ];

        # ── Workspaces par défaut (DP-1 = principal) ────────────
        workspace = [
          "1, monitor:DP-1, default:true"
          "2, monitor:DP-1"
          "3, monitor:DP-1"
          "4, monitor:DP-1"
          "5, monitor:DP-1"
          "6, monitor:DP-3"
          "7, monitor:DP-3"
          "8, monitor:DP-3"
          "9, monitor:DP-3"
          "10, monitor:DP-3"
        ];

        # ── Entrée ────────────────────────────────────────────────
        input = {
          kb_layout = "fr";
          follow_mouse = 1;
          sensitivity = 0;
        };

        # ── Import thème Catppuccin ───────────────────────────────
        source = themeCfg.hyprlandThemeFile;

        # ── Apparence ─────────────────────────────────────────────
        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          "col.active_border" = "$mauve $blue 45deg";
          "col.inactive_border" = "$surface0";
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
            color = "rgba(0, 0, 0, 0.4)";
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

        # ── Variables d'environnement ─────────────────────────────
        env = [
          # Nvidia
          "LIBVA_DRIVER_NAME,nvidia"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          "ELECTRON_OZONE_PLATFORM_HINT,auto"
          "NVD_BACKEND,direct"
        ];

        cursor = {
          no_hardware_cursors = true;
          default_monitor = "DP-1";
        };

        # ── Autostart ─────────────────────────────────────────────
        exec-once = [
          "uwsm app -- hyprlock"
          "uwsm app -- waybar"
          "uwsm app -- hypridle"
          "uwsm app -- dunst"
        ];

        # ── Raccourcis clavier ────────────────────────────────────
        "$mod" = "SUPER";

        bind = [
          "$mod, Escape, exec, uwsm app -- hyprlock"
          "$mod, Return, exec, uwsm app -- kitty"
          "$mod, Q, killactive"
          "$mod, M, exec, power-menu"
          "$mod, E, exec, uwsm app -- kitty -e yazi"
          "$mod, V, togglefloating"
          "$mod, D, exec, uwsm app -- wofi --show drun"
          "$mod, F, fullscreen"
          "$mod, P, pseudo"
          "$mod, S, togglesplit"

          # Déplacement du focus
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # Déplacer une fenêtre dans les directions (HJKL)
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, L, movewindow, r"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, J, movewindow, d"

          # Déplacer une fenêtre vers l'autre écran
          "$mod SHIFT, left, movewindow, mon:-1"
          "$mod SHIFT, right, movewindow, mon:+1"

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

        # Touches multimédia (fallback clavier standard)
        bindel = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 2%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
        ];

        bindl = [
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ];

        # Déplacement / redimensionnement souris
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
