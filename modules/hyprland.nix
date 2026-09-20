{ ... }:
{
  den.aspects.hyprland = {
    nixos = { pkgs, host, ... }: {
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

      # greetd/noctalia-greeter own the actual login flow — see
      # noctalia-greeter.nix.
      services.displayManager.defaultSession = "hyprland-uwsm";

      # Suspend-key/lid-switch behavior is a host preference (e.g. a laptop
      # wants HandleLidSwitch to actually suspend) — see hosts.nix.
      services.logind.settings.Login = host.hyprland.logindOverrides;

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
    };

    homeManager = { pkgs, lib, host, ... }:
      let
        # Host display settings and defaults are declared in schema.nix.
        hypr = host.hyprland;
      in
      {
        home.sessionVariables = {
          NIXOS_OZONE_WL = "1";
        };

        home.file."Images/Wallpapers/wallpaper.png".source = ../wallpapers/wallpaper.png;

        home.packages = with pkgs; [
          wl-clipboard
          grim
          slurp
          pavucontrol
          brightnessctl
        ];

        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = false;
          configType = "lua";
          # Deterministic render order for `settings` below (module default is
          # alphabetical + a fixed prefix list that doesn't match our keys).
          # `colors` is catppuccin's Lua palette, needed before `config` uses it.
          importantPrefixes = [ "colors" "monitor" "workspace_rule" "env" "config" "curve" "animation" ];
          settings = {
            monitor = hypr.monitors;
            workspace_rule = hypr.workspaceRules;

            env = [
              { _args = [ "ELECTRON_OZONE_PLATFORM_HINT" "auto" ]; }
            ] ++ lib.optionals hypr.nvidia [
              { _args = [ "LIBVA_DRIVER_NAME" "nvidia" ]; }
              { _args = [ "__GLX_VENDOR_LIBRARY_NAME" "nvidia" ]; }
              { _args = [ "NVD_BACKEND" "direct" ]; }
            ];

            config = {
              input = {
                kb_layout = "fr";
                follow_mouse = 1;
                sensitivity = 0;
              };
              general = {
                gaps_in = 4;
                gaps_out = 8;
                border_size = 2;
                col = {
                  active_border = lib.generators.mkLuaInline "colors.accent";
                  inactive_border = lib.generators.mkLuaInline "colors.surface0";
                };
                layout = "dwindle";
              };
              decoration = {
                rounding = 8;
                blur = { enabled = true; size = 6; passes = 2; brightness = 1.2; contrast = 1.0; vibrancy = 0.0; };
                shadow = { enabled = true; range = 12; render_power = 3; color = "0x66000000"; };
              };
              # Outputs already use HDR. Automatic fullscreen switching causes
              # washed-out Brave video; keep the configured output color mode.
              render.cm_auto_hdr = 0;
              animations = { enabled = true; };
              dwindle = { preserve_split = true; };
              misc = { force_default_wallpaper = 0; disable_hyprland_logo = true; };
              cursor =
                lib.optionalAttrs (hypr.defaultMonitor != null) { default_monitor = hypr.defaultMonitor; }
                // lib.optionalAttrs hypr.nvidia { no_hardware_cursors = 2; };
            };

            curve = { _args = [ "ease" { type = "bezier"; points = [ [ 0.25 0.1 ] [ 0.25 1 ] ]; } ]; };

            animation = [
              { leaf = "windows"; enabled = true; speed = 4; bezier = "ease"; }
              { leaf = "windowsOut"; enabled = true; speed = 4; bezier = "ease"; style = "popin 80%"; }
              { leaf = "fade"; enabled = true; speed = 4; bezier = "ease"; }
              { leaf = "workspaces"; enabled = true; speed = 3; bezier = "ease"; }
            ];
          };
          # Desktop keybinds use Ghostty, Noctalia and PipeWire, included by pierre.
          extraConfig = ''
            -- Keybinds
            local mod = "SUPER"

            hl.bind(mod .. " + Return", hl.dsp.exec_cmd("uwsm app -- ghostty +new-window --working-directory=home"))
            hl.bind(mod .. " + Q",      hl.dsp.window.close())
            hl.bind(mod .. " + M",      hl.dsp.exec_cmd("noctalia msg panel-toggle session"))
            hl.bind(mod .. " + E",      hl.dsp.exec_cmd("uwsm app -- ghostty +new-window -e yazi"))
            hl.bind(mod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
            hl.bind(mod .. " + D",      hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
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
              'geometry=$(slurp -d) && test -n "$geometry" && mkdir -p ~/Pictures/Screenshots && f=~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png && grim -g "$geometry" "$f" && wl-copy < "$f"'
            ))

            -- Audio
            hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 2%+"), { locked = true, repeating = true })
            hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), { locked = true, repeating = true })
            hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),    { locked = true })
            hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

            -- Mouse
            hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
            hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
          '';
        };
      };
  };
}
