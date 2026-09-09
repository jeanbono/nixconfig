{
  # Real greetd greeter (PAM auth as the restricted "greeter" system user)
  # in front of the session, instead of greetd autologin-ing straight into
  # pierre's Hyprland session — Caelestia's own lock is an in-session
  # locker, not a pre-session authenticator, so it never actually gated
  # session creation. tuigreet needs no compositor of its own (runs on the
  # console via greetd's useTextGreeter mode), so it's unaffected by the
  # multi-monitor/NVIDIA setup that a graphical greeter would have to
  # contend with.
  den.aspects.greeter.nixos = { pkgs, lib, ... }: {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings.default_session.command = lib.concatStringsSep " " [
        "${pkgs.tuigreet}/bin/tuigreet"
        "--remember"
        "--time"
        "--asterisks"
        "--cmd 'uwsm start hyprland-uwsm.desktop'"
      ];
      # default_session.user stays at the module's own default ("greeter"):
      # no autologin, real PAM authentication gates session creation.
    };
  };
}
