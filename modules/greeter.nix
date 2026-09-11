{
  # tuigreet authenticates through PAM on a text console before starting Hyprland.
  den.aspects.greeter.nixos = { pkgs, lib, ... }: {
    # Driver errors printed after tuigreet starts can corrupt its TUI.
    # Keep critical messages on the console; ordinary errors remain in
    # the kernel journal (journalctl -k), including Bluetooth retries.
    boot.consoleLogLevel = 3;

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
