let
  lockBeforeSleep = false;
  roundingScale = 0.6;
  borderRounding = 12;
  desktopClock = true;
  idleTimeouts = [
    { timeout = 300; idleAction = "lock"; returnAction = null; }
    { timeout = 600; idleAction = "dpms off"; returnAction = "dpms on"; }
  ];
in
{
  den.aspects.caelestia.homeManager = { pkgs, config, ... }: {
    # Read by the dashboard as the profile picture (caelestia-shell convention).
    home.file.".face".source = ../assets/face.png;

    programs.caelestia = {
      enable = true;
      systemd.enable = true;
      cli.enable = true;
      settings = {
        general.idle.lockBeforeSleep = lockBeforeSleep;
        general.idle.timeouts = map
          (t: { inherit (t) timeout idleAction; }
            // (if t.returnAction != null then { inherit (t) returnAction; } else { }))
          idleTimeouts;
        appearance.rounding.scale = roundingScale;
        border.rounding = borderRounding;
        background.desktopClock.enabled = desktopClock;
        session.commands.logout   = ["systemd-run" "--user" "--scope" "hyprshutdown" "-t" "Logging out..."];
        session.commands.shutdown = ["systemd-run" "--user" "--scope" "hyprshutdown" "-t" "Shutting down..." "-p" "poweroff"];
        session.commands.reboot   = ["systemd-run" "--user" "--scope" "hyprshutdown" "-t" "Restarting..."   "-p" "reboot"];
      };
    };

    systemd.user.services.lock-on-start = {
      Unit = {
        Description = "Lock session on startup and resume via caelestia";
        # Without this ordering, this service and `caelestia.service` (the shell)
        # both start on `graphical-session.target` with no constraint between them.
        After = [ "graphical-session.target" "caelestia.service" ];
      };
      Service = {
        Type = "oneshot";
        # Pattern recommended by the caelestia-dots maintainers (shell#176
        # discussion): `shell -d` blocks until the shell is actually ready
        # (even if it's already running via caelestia.service, it detects the
        # existing instance and returns), so the following `lock` can no
        # longer run too early — no more sleep or retry needed.
        ExecStart = [
          "${config.programs.caelestia.cli.package}/bin/caelestia shell -d"
          "${config.programs.caelestia.cli.package}/bin/caelestia shell lock lock"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
