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
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
        ExecStart = "${config.programs.caelestia.cli.package}/bin/caelestia shell lock lock";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
