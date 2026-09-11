{ inputs, ... }:
let
  lockBeforeSleep = true;
  roundingScale = 0.6;
  borderRounding = 12;
  desktopClock = true;
  idleTimeouts = [
    { timeout = 300; idleAction = "lock"; returnAction = null; }
    { timeout = 600; idleAction = "dpms off"; returnAction = "dpms on"; }
  ];
in
{
  den.aspects.caelestia.homeManager = { host, ... }: {
    imports = [ inputs.caelestia-shell.homeManagerModules.default ];

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
        # Host overrides, with defaults from Caelestia's barconfig.hpp.
        bar.statusIcons = (host.caelestia or { }).statusIcons or [
          { id = "lockStatus"; enabled = true; }
          { id = "audio"; enabled = false; }
          { id = "microphone"; enabled = false; }
          { id = "kbLayout"; enabled = false; }
          { id = "network"; enabled = true; }
          { id = "bluetooth"; enabled = true; }
          { id = "battery"; enabled = true; }
        ];
        # Switch to greetd's VT explicitly to avoid a black screen on NVIDIA.
        session.commands.logout   = ["systemd-run" "--user" "--scope" "hyprshutdown" "-t" "Logging out..." "--vt" "1"];
        session.commands.shutdown = ["systemd-run" "--user" "--scope" "hyprshutdown" "-t" "Shutting down..." "-p" "poweroff" "--vt" "1"];
        session.commands.reboot   = ["systemd-run" "--user" "--scope" "hyprshutdown" "-t" "Restarting..."   "-p" "reboot" "--vt" "1"];
      };
    };
  };
}
