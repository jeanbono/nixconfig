let
  keyringEnvironment = {
    PROTON_PASS_KEY_PROVIDER = "keyring";
    PROTON_PASS_LINUX_KEYRING = "dbus";
  };
in
{
  den.aspects.protonpass = {
    nixos = { pkgs, ... }: {
      services.gnome.gnome-keyring.enable = true;
      # PAM passes the login password to the login keyring.
      security.pam.services.greetd.enableGnomeKeyring = true;

      environment.systemPackages = with pkgs; [
        proton-pass
        proton-pass-cli
      ];

      # The Brave force-install policy for the ProtonPass extension is owned
      # by den.aspects.brave (see its comment): Chromium doesn't safely merge
      # the same managed policy across two separate *.json files.
    };

    homeManager = { pkgs, lib, user, ... }: {
      # Interactive login and the agent must use the same persistent backend.
      home.sessionVariables = keyringEnvironment // {
        SSH_AUTH_SOCK = "$HOME/.ssh/proton-pass-agent.sock";
      };

      programs.ssh.settings."*".identityAgent = "~/.ssh/proton-pass-agent.sock";

      systemd.user.services.protonpass-ssh-agent = {
        Unit = {
          Description = "ProtonPass CLI SSH Agent";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStartPre = "${pkgs.networkmanager}/bin/nm-online -q --timeout=30";
          ExecStart = "${pkgs.proton-pass-cli}/bin/pass-cli ssh-agent start --create-new-identities ${user.protonPassIdentity}";
          Restart = "on-failure";
          RestartSec = "5s";
          Environment = (lib.mapAttrsToList (name: value: "${name}=${value}") keyringEnvironment) ++ [
            "SSH_AUTH_SOCK=%h/.ssh/proton-pass-agent.sock"
          ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
