{ pkgs, lib, config, ... }:

let
  cfg = config.modules.hyprland;

  rose-pine-hyprcursor = pkgs.fetchFromGitHub {
    owner = "ndom91";
    repo = "rose-pine-hyprcursor";
    rev = "main";
    sha256 = "sha256-ouuA8LVBXzrbYwPW2vNjh7fC9H2UBud/1tUiIM5vPvM=";
  };

  # Couleurs Catppuccin embarquées (remplace le source = .conf qui n'est plus possible en Lua)
  catppuccinColors = {
    latte     = { mauve = "0xffdc8a78"; blue = "0xff1e66f5"; surface0 = "0xffccd0da"; };
    frappe    = { mauve = "0xffca9ee6"; blue = "0xff8caaee"; surface0 = "0xff414559"; };
    macchiato = { mauve = "0xffc6a0f6"; blue = "0xff8aadf4"; surface0 = "0xff363a4f"; };
    mocha     = { mauve = "0xffcba6f7"; blue = "0xff89b4fa"; surface0 = "0xff313244"; };
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
        colors = catppuccinColors.${themeCfg.flavor};
      in
      {
        home.sessionVariables = {
          NIXOS_OZONE_WL = "1";
          HYPRCURSOR_THEME = "rose-pine-hyprcursor";
          HYPRCURSOR_SIZE = "24";
        };

        home.file.".local/share/icons/rose-pine-hyprcursor".source = rose-pine-hyprcursor;
        home.file."Images/Wallpapers/wallpaper.png".source = ../wallpapers/wallpaper.png;

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
          configType = "lua";
          extraConfig = ''
            -- Monitors
            hl.monitor({ output = "DP-3", mode = "2560x1440@165", position = "0x0",    scale = 1, bitdepth = 10, cm = "hdr", sdrbrightness = 2.3 })
            hl.monitor({ output = "DP-1", mode = "2560x1440@300", position = "2560x0", scale = 1, bitdepth = 10, cm = "hdr", sdrbrightness = 2.3 })

            -- Workspace → monitor assignment
            hl.workspace_rule({ workspace = "1",  monitor = "DP-1", default = true })
            hl.workspace_rule({ workspace = "2",  monitor = "DP-1" })
            hl.workspace_rule({ workspace = "3",  monitor = "DP-1" })
            hl.workspace_rule({ workspace = "4",  monitor = "DP-1" })
            hl.workspace_rule({ workspace = "5",  monitor = "DP-1" })
            hl.workspace_rule({ workspace = "6",  monitor = "DP-3" })
            hl.workspace_rule({ workspace = "7",  monitor = "DP-3" })
            hl.workspace_rule({ workspace = "8",  monitor = "DP-3" })
            hl.workspace_rule({ workspace = "9",  monitor = "DP-3" })
            hl.workspace_rule({ workspace = "10", monitor = "DP-3" })

            -- Env
            hl.env("LIBVA_DRIVER_NAME",            "nvidia")
            hl.env("__GLX_VENDOR_LIBRARY_NAME",    "nvidia")
            hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
            hl.env("NVD_BACKEND",                  "direct")

            -- Config
            hl.config({
              input = {
                kb_layout    = "fr",
                follow_mouse = 1,
                sensitivity  = 0,
              },
              general = {
                gaps_in     = 4,
                gaps_out    = 8,
                border_size = 2,
                col = {
                  active_border   = { colors = { "${colors.mauve}", "${colors.blue}" }, angle = 45 },
                  inactive_border = "${colors.surface0}",
                },
                layout = "dwindle",
              },
              decoration = {
                rounding = 8,
                blur   = { enabled = true, size = 6, passes = 2, brightness = 1.2, contrast = 1.0, vibrancy = 0.0 },
                shadow = { enabled = true, range = 12, render_power = 3, color = "0x66000000" },
              },
              animations = { enabled = true },
              dwindle = { preserve_split = true },
              misc    = { force_default_wallpaper = 0, disable_hyprland_logo = true },
              cursor  = { no_hardware_cursors = 2, default_monitor = "DP-1" },
              render  = { use_fp16 = 2, ctm_animation = false },
            })

            hl.curve("ease", { type = "bezier", points = { {0.25, 0.1}, {0.25, 1} } })
            hl.animation({ leaf = "windows",    enabled = true, speed = 4, bezier = "ease" })
            hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "ease", style = "popin 80%" })
            hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "ease" })
            hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "ease" })

            -- Keybinds
            local mod = "SUPER"

            hl.bind(mod .. " + Return", hl.dsp.exec_cmd("uwsm app -- alacritty"))
            hl.bind(mod .. " + Q",      hl.dsp.window.close())
            hl.bind(mod .. " + M",      hl.dsp.exec_cmd("caelestia shell drawers toggle session"))
            hl.bind(mod .. " + E",      hl.dsp.exec_cmd("uwsm app -- alacritty -e yazi"))
            hl.bind(mod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
            hl.bind(mod .. " + D",      hl.dsp.exec_cmd("caelestia shell drawers toggle launcher"))
            hl.bind(mod .. " + F",      hl.dsp.window.fullscreen())
            hl.bind(mod .. " + S",      hl.dsp.layout("togglesplit"))

            hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
            hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
            hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
            hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

            hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
            hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
            hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
            hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

            local function move_to_monitor(dir)
              return function()
                local active = hl.get_active_monitor()
                if not active then return end
                for _, mon in ipairs(hl.get_monitors()) do
                  if mon.id ~= active.id then
                    local ok = (dir == "l" and mon.x + mon.width <= active.x)
                            or (dir == "r" and mon.x >= active.x + active.width)
                    if ok then hl.dispatch(hl.dsp.window.move({ monitor = dir })) return end
                  end
                end
              end
            end

            hl.bind(mod .. " + SHIFT + left",  move_to_monitor("l"))
            hl.bind(mod .. " + SHIFT + right", move_to_monitor("r"))

            -- Workspaces (AZERTY)
            hl.bind(mod .. " + ampersand",  hl.dsp.focus({ workspace = 1 }))
            hl.bind(mod .. " + eacute",     hl.dsp.focus({ workspace = 2 }))
            hl.bind(mod .. " + quotedbl",   hl.dsp.focus({ workspace = 3 }))
            hl.bind(mod .. " + apostrophe", hl.dsp.focus({ workspace = 4 }))
            hl.bind(mod .. " + parenleft",  hl.dsp.focus({ workspace = 5 }))
            hl.bind(mod .. " + minus",      hl.dsp.focus({ workspace = 6 }))
            hl.bind(mod .. " + egrave",     hl.dsp.focus({ workspace = 7 }))
            hl.bind(mod .. " + underscore", hl.dsp.focus({ workspace = 8 }))
            hl.bind(mod .. " + ccedilla",   hl.dsp.focus({ workspace = 9 }))
            hl.bind(mod .. " + agrave",     hl.dsp.focus({ workspace = 10 }))

            hl.bind(mod .. " + SHIFT + ampersand",  hl.dsp.window.move({ workspace = 1 }))
            hl.bind(mod .. " + SHIFT + eacute",     hl.dsp.window.move({ workspace = 2 }))
            hl.bind(mod .. " + SHIFT + quotedbl",   hl.dsp.window.move({ workspace = 3 }))
            hl.bind(mod .. " + SHIFT + apostrophe", hl.dsp.window.move({ workspace = 4 }))
            hl.bind(mod .. " + SHIFT + parenleft",  hl.dsp.window.move({ workspace = 5 }))
            hl.bind(mod .. " + SHIFT + minus",      hl.dsp.window.move({ workspace = 6 }))
            hl.bind(mod .. " + SHIFT + egrave",     hl.dsp.window.move({ workspace = 7 }))
            hl.bind(mod .. " + SHIFT + underscore", hl.dsp.window.move({ workspace = 8 }))
            hl.bind(mod .. " + SHIFT + ccedilla",   hl.dsp.window.move({ workspace = 9 }))
            hl.bind(mod .. " + SHIFT + agrave",     hl.dsp.window.move({ workspace = 10 }))

            hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
            hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

            -- Screenshot
            hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd(
              'mkdir -p ~/Pictures/Screenshots && f=~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png && grim -g "$(slurp -d)" "$f" && wl-copy < "$f"'
            ))

            -- Audio
            hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"), { locked = true, repeating = true })
            hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), { locked = true, repeating = true })
            hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),    { locked = true })
            hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

            -- Mouse
            hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
            hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
          '';
        };
      }
    );
  };
}
