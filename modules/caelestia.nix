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
        # Sans cet ordre, ce service et `caelestia.service` (le shell) démarrent
        # tous les deux sur `graphical-session.target` sans contrainte entre eux.
        After = [ "graphical-session.target" "caelestia.service" ];
      };
      Service = {
        Type = "oneshot";
        # Pattern recommandé par les mainteneurs caelestia-dots (discussion
        # shell#176) : `shell -d` bloque jusqu'à ce que le shell soit vraiment
        # prêt (même s'il tourne déjà via caelestia.service, il détecte
        # l'instance existante et rend la main), donc `lock` qui suit ne peut
        # plus arriver trop tôt — plus besoin de sleep ni de retry.
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
