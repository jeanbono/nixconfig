{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hyprland;

  rose-pine-hyprcursor = pkgs.fetchFromGitHub {
    owner = "ndom91";
    repo = "rose-pine-hyprcursor";
    rev = "main";
    sha256 = "sha256-ouuA8LVBXzrbYwPW2vNjh7fC9H2UBud/1tUiIM5vPvM=";
  };
in
{
  options.modules.hyprland = {
    enable = lib.mkEnableOption "Hyprland : compositor (NixOS) + session utilisateur (HM)";
    user = lib.mkOption {
      type = lib.types.str;
      description = "Utilisateur pour l'auto-login greetd";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = !config.modules.plasma.enable;
      message = "modules.hyprland et modules.plasma sont mutuellement exclusifs";
    }];

    # ── NixOS : compositor, portails, polices, greetd ──────────────────────
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };

    programs.dconf.enable = true;
    programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "uwsm start hyprland-uwsm.desktop";
        user = cfg.user;
      };
    };

    services.displayManager.defaultSession = "hyprland-uwsm";

    services.logind.settings.Login = {
      HandleSuspendKey = "ignore";
      HandleSuspendKeyLongPress = "ignore";
      HandleLidSwitch = "ignore";
    };

    fonts.packages = with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.monaspace
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    fonts.fontconfig = {
      enable = true;
      antialias = true;
      hinting = { enable = true; style = "slight"; };
      subpixel = { rgba = "none"; lcdfilter = "default"; };
    };

    # ── HM : session wayland, keybinds, moniteurs, yazi, curseur ──────────
    home-manager.users = lib.genAttrs config.modules.users (user:
      { nixosConfig, pkgs, lib, ... }:
      let
        themeCfg = nixosConfig.modules.theme.catppuccin;
      in
      {
        home.sessionVariables = {
          NIXOS_OZONE_WL = "1";
          HYPRCURSOR_THEME = "rose-pine-hyprcursor";
          HYPRCURSOR_SIZE = "24";
        };

        home.file.".local/share/icons/rose-pine-hyprcursor".source = rose-pine-hyprcursor;
        home.file."Pictures/Wallpapers/wallpaper.png".source = ../wallpapers/wallpaper.png;

        home.packages = with pkgs; [
          wl-clipboard
          grim
          slurp
          pavucontrol
          brightnessctl
          hyprcursor
          hyprshutdown
          rose-pine-cursor
        ];

        gtk.cursorTheme = {
          name = "BreezeX-RosePine-Linux";
          package = pkgs.rose-pine-cursor;
          size = 24;
        };

        programs.yazi = {
          enable = true;
          enableZshIntegration = true;
          shellWrapperName = "y";
          settings = {
            manager = {
              show_hidden = false;
              sort_by = "natural";
              sort_dir_first = true;
            };
          };
          theme.flavor.use = themeCfg.flavor;
          flavors.${themeCfg.flavor} = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "yazi";
            rev = "main";
            sha256 = "sha256-Og33IGS9pTim6LEH33CO102wpGnPomiperFbqfgrJjw=";
          };
        };

        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = false;
          settings = {
            monitor = [
              "DP-3, 2560x1440@165, 0x0, 1, bitdepth, 10, cm, hdr, sdrbrightness, 1.3"
              "DP-1, 2560x1440@300, 2560x0, 1, bitdepth, 10, cm, hdr, sdrbrightness, 1.3"
            ];
            workspace = [
              "1, monitor:DP-1, default:true" "2, monitor:DP-1" "3, monitor:DP-1"
              "4, monitor:DP-1" "5, monitor:DP-1"
              "6, monitor:DP-3" "7, monitor:DP-3" "8, monitor:DP-3"
              "9, monitor:DP-3" "10, monitor:DP-3"
            ];
            input = { kb_layout = "fr"; follow_mouse = 1; sensitivity = 0; };
            source = themeCfg.hyprlandThemeFile;
            general = {
              gaps_in = 4; gaps_out = 8; border_size = 2;
              "col.active_border" = "$mauve $blue 45deg";
              "col.inactive_border" = "$surface0";
              layout = "dwindle";
            };
            decoration = {
              rounding = 8;
              blur = { enabled = true; size = 6; passes = 2; };
              shadow = { enabled = true; range = 12; render_power = 3; color = "rgba(0,0,0,0.4)"; };
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
            dwindle = { pseudotile = true; preserve_split = true; };
            misc = { force_default_wallpaper = 0; disable_hyprland_logo = true; };
            env = [
              "LIBVA_DRIVER_NAME,nvidia"
              "__GLX_VENDOR_LIBRARY_NAME,nvidia"
              "ELECTRON_OZONE_PLATFORM_HINT,auto"
              "NVD_BACKEND,direct"
            ];
            cursor = { no_hardware_cursors = true; default_monitor = "DP-1"; };
            "$mod" = "SUPER";
            bind = [
              "$mod, Return, exec, uwsm app -- alacritty"
              "$mod, Q, killactive"
              "$mod, M, exec, caelestia shell drawers toggle session"
              "$mod, E, exec, uwsm app -- alacritty -e yazi"
              "$mod, V, togglefloating"
              "$mod, D, exec, caelestia shell drawers toggle launcher"
              "$mod, F, fullscreen"
              "$mod, P, pseudo"
              "$mod, S, layoutmsg, togglesplit"
              "$mod, left, movefocus, l"   "$mod, right, movefocus, r"
              "$mod, up, movefocus, u"     "$mod, down, movefocus, d"
              "$mod SHIFT, H, movewindow, l" "$mod SHIFT, L, movewindow, r"
              "$mod SHIFT, K, movewindow, u" "$mod SHIFT, J, movewindow, d"
              "$mod SHIFT, left, movewindow, mon:-1"
              "$mod SHIFT, right, movewindow, mon:+1"
              "$mod, ampersand, workspace, 1"  "$mod, eacute, workspace, 2"
              "$mod, quotedbl, workspace, 3"   "$mod, apostrophe, workspace, 4"
              "$mod, parenleft, workspace, 5"  "$mod, minus, workspace, 6"
              "$mod, egrave, workspace, 7"     "$mod, underscore, workspace, 8"
              "$mod, ccedilla, workspace, 9"   "$mod, agrave, workspace, 10"
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
              "$mod, mouse_down, workspace, e+1"
              "$mod, mouse_up, workspace, e-1"
              ''$mod SHIFT, S, exec, mkdir -p ~/Pictures/Screenshots && f=~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png && grim -g "$(slurp -d)" "$f" && wl-copy < "$f"''
            ];
            bindel = [
              ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
              ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
            ];
            bindl = [
              ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
              ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            ];
            bindm = [
              "$mod, mouse:272, movewindow"
              "$mod, mouse:273, resizewindow"
            ];
          };
        };
      }
    );
  };
}
