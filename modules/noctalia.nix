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
        # No other polkit authentication agent runs in this session, so an
        # interactive prompt (e.g. the greeter's appearance-sync fallback)
        # has nowhere to render without this.
        shell.polkit_agent = true;
        # Auto-push wallpaper/palette/font/output config to
        # noctalia-greeter's sync.toml on every change instead of requiring
        # a manual "Sync Now" (see noctalia-greeter.nix's
        # passwordless-sync-users).
        shell.greeter_sync.auto_sync = true;
        # Detached panels (control center, session menu, ...) use this
        # separate 3-preset transparency setting, not bar.default's
        # opacity slider. "soft" ~= 0.80 opacity, matching the bar below.
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
        # Per-widget settings live in a top-level [widget.<name>] table,
        # not nested under bar.default. macOS-style clock with date
        # (locale-aware, e.g. "mar. 15 sept. 16:04").
        widget.clock.format = "{:%a %d %b %H:%M}";
        lockscreen = {
          blurred_desktop = true;
          blur_intensity = 0.75;
        };
        # noctalia's default idle behaviors ship disabled: lock at 5min,
        # screen off (DPMS) at 10min. No RAM suspend.
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
        # Keep native session actions: an external logout splash conflicts
        # with the session lock when invoked from the lockscreen.
      };
    };
  };
}
