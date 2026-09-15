{ inputs, ... }:
{
  den.aspects.noctalia.homeManager = { config, ... }: {
    imports = [ inputs.noctalia.homeModules.default ];

    # AccountsService (used by both noctalia-shell and noctalia-greeter for
    # the profile picture) defaults to $HOME/.face when a user has no
    # explicit Icon= override (accountsservice's user_reset_icon_file()).
    home.file.".face".source = ../assets/face.png;

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings = {
        theme = {
          mode = "dark";
          # "builtin" Catppuccin is actually Mocha-shaded; the community
          # palette below matches the Macchiato flavor used elsewhere
          # (theme.nix, ghostty.nix, brave.nix).
          source = "community";
          community_palette = "Catppuccin Macchiato Blue";
          wallpaper_scheme = "m3-content";
        };
        shell.font_family = "MonaspiceNe Nerd Font";
        # No other polkit authentication agent runs in this session (there
        # never was one under Caelestia+tuigreet either, but nothing
        # exercised an interactive polkit prompt until Noctalia Greeter's
        # appearance-sync fallback). Without an agent, an interactive
        # prompt has nowhere to render.
        shell.polkit_agent = true;
        # Auto-push wallpaper/palette/font/output config to
        # noctalia-greeter's sync.toml on every change instead of requiring
        # a manual "Sync Now" (see noctalia-greeter.nix's
        # passwordless-sync-users).
        shell.greeter_sync.auto_sync = true;
        # Detached panels (control center, session menu, ...) have their
        # own separate transparency mechanism, unrelated to bar.default's
        # opacity slider: 3 discrete presets, not a continuous value.
        # "soft" resolves to background opacity 0.80
        # (detachedPanelBackgroundOpacityForTransparencyMode() in
        # config_types.cpp), matching bar.default.background_opacity below
        # ("glass" would be 0.55, "solid" -- the default -- is fully
        # opaque, which is why panels didn't match the bar after only
        # tuning bar.default).
        shell.panel.transparency_mode = "soft";
        bar.default = {
          background_opacity = 0.8;
          capsule = true;
          capsule_opacity = 0.8;
          concave_edge_corners = false;
          margin_ends = 0;
          radius = 0;
          # macOS-style layout: app/workspace switching on the left, status
          # icons grouped on the right with the clock near the far edge
          # (default puts the clock in its own center section instead).
          start = [ "launcher" "workspaces" ];
          center = [ ];
          end = [
            "tray"
            "network"
            "bluetooth"
            "volume"
            "brightness"
            "battery"
            "notifications"
            "control-center"
            "clock"
            "session"
          ];
        };
        # Per-widget instance settings live in a separate top-level
        # [widget.<name>] table, not nested under bar.default. Format is
        # C++'s chrono/std::format spec (locale-aware: %a/%b render in
        # fr_FR, e.g. "mar. 15 sept. 16:04"), matching macOS's menu-bar
        # clock style.
        widget.clock.format = "{:%a %d %b %H:%M}";
        lockscreen = {
          blurred_desktop = true;
          blur_intensity = 0.75;
        };
        # All of noctalia's default idle behaviors ship disabled
        # (defaultIdleBehaviors() in config_types.cpp) -- restores
        # Caelestia's old general.idle.timeouts: lock at 5min, screen off
        # (DPMS) at 10min. Never actually suspended to RAM under Caelestia
        # either, despite the "lock-and-suspend" behavior existing here.
        idle.behavior = {
          lock = {
            enabled = true;
            timeout = 300;
            action = "lock";
          };
          "screen-off" = {
            enabled = true;
            timeout = 600;
            action = "screen_off";
          };
        };
        wallpaper = {
          enabled = true;
          # Same file hyprland.nix deploys to ~/Images/Wallpapers; picked
          # over the repo's own ../wallpapers store path directly from
          # Noctalia's settings UI, which browses under $HOME.
          directory = "${config.home.homeDirectory}/Images/Wallpapers";
          fill_mode = "crop";
        };
        # Switch to greetd's VT explicitly to avoid a black screen on
        # NVIDIA, showing hyprshutdown's splash during the transition.
        # Declaring any entry replaces noctalia's default session.actions
        # wholesale (defaultSessionPanelActions() in config_types.cpp), so
        # lock/lock_and_suspend are repeated here unmodified, matching that
        # default (including their keybinds).
        shell.session.actions = [
          { action = "lock"; shortcut = "1"; }
          {
            action = "logout";
            shortcut = "2";
            command = "systemd-run --user --scope hyprshutdown -t 'Logging out...' --vt 1";
          }
          { action = "lock_and_suspend"; shortcut = "3"; }
          {
            action = "reboot";
            shortcut = "4";
            command = "systemd-run --user --scope hyprshutdown -t 'Restarting...' -p reboot --vt 1";
          }
          {
            action = "shutdown";
            shortcut = "5";
            variant = "destructive";
            command = "systemd-run --user --scope hyprshutdown -t 'Shutting down...' -p poweroff --vt 1";
          }
        ];
      };
    };
  };
}
