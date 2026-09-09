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
  den.aspects.caelestia.homeManager = { ... }: {
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
        # --vt 1 forces a VT switch after Hyprland exits: on NVIDIA,
        # greetd/tuigreet's own VT (services.greetd.settings.terminal.vt,
        # fixed to 1) otherwise doesn't repaint and logout leaves a black
        # screen instead of returning to the greeter (hyprshutdown --help
        # documents this as "fixes NVIDIA+SDDM black screen").
        session.commands.logout   = ["systemd-run" "--user" "--scope" "hyprshutdown" "-t" "Logging out..." "--vt" "1"];
        session.commands.shutdown = ["systemd-run" "--user" "--scope" "hyprshutdown" "-t" "Shutting down..." "-p" "poweroff" "--vt" "1"];
        session.commands.reboot   = ["systemd-run" "--user" "--scope" "hyprshutdown" "-t" "Restarting..."   "-p" "reboot" "--vt" "1"];
      };
    };
  };
}
