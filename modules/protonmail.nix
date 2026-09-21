{
  den.aspects.protonmail.homeManager = { pkgs, ... }: {
    # Includes the IMAP/SMTP backend; credentials use the host's GNOME Keyring.
    home.packages = [ pkgs.protonmail-bridge-gui ];

    # Bridge's own autostart bypasses the Nix Qt wrapper and races our service.
    # Replace any existing entry; systemd is the sole startup owner.
    xdg.configFile."autostart/ProtonMailBridge.desktop" = {
      force = true;
      text = ''
        [Desktop Entry]
        Type=Application
        Name=ProtonMailBridge
        Hidden=true
      '';
    };

    systemd.user.services.protonmail-bridge = {
      Unit = {
        Description = "Proton Mail Bridge";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.protonmail-bridge-gui}/bin/protonmail-bridge-gui --no-window";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
