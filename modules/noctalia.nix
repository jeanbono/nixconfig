{ inputs, ... }:
{
  den.aspects.noctalia.homeManager = { config, ... }:
    let
      # Under $HOME rather than the store so Noctalia's settings UI, which
      # browses from $HOME, can find it.
      wallpaper = "${config.xdg.userDirs.pictures}/Wallpapers/wallpaper.png";
    in
    {
      # AccountsService (used by both noctalia-shell and noctalia-greeter for
      # the profile picture) defaults to $HOME/.face when a user has no
      # explicit Icon= override (accountsservice's user_reset_icon_file()).
      home.file.".face".source = ../assets/face.png;
      home.file.${wallpaper}.source = ../wallpapers/wallpaper.png;

      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        settings = {
          location.auto_locate = true;
          weather = {
            enabled = true;
            unit = "celsius";
          };
          theme = {
            mode = "dark";
            # Noctalia downloads and caches the community palette natively.
            source = "community";
            community_palette = inputs.self.lib.theme.name;
            wallpaper_scheme = "m3-content";
            # Only GTK follows Noctalia (catppuccin/nix has no GTK theme); other
            # applications are themed by catppuccin/nix.
            templates = {
              enable_builtin_templates = true;
              builtin_ids = [ "gtk3" "gtk4" ];
              enable_community_templates = false;
            };
          };
          shell.font_family = inputs.self.lib.theme.font;
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
          shell.screenshot.directory = "${config.xdg.userDirs.pictures}/Screenshots";
          wallpaper = {
            enabled = true;
            directory = dirOf wallpaper;
            # Read from the merged config; a wallpaper picked in the UI is
            # saved to the state file and takes precedence.
            default.path = wallpaper;
            fill_mode = "crop";
          };
          # Keep native session actions: an external logout splash conflicts
          # with the session lock when invoked from the lockscreen.
        };
      };
    };
}
