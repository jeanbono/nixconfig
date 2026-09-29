{
  den.aspects.protonpass = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        proton-pass
        proton-pass-cli
      ];

      # gnome-keyring enables gcr's SSH agent by default, which would export a
      # competing SSH_AUTH_SOCK into the systemd user environment.
      services.gnome.gcr-ssh-agent.enable = false;

      # The Brave force-install policy for the ProtonPass extension is owned
      # by den.aspects.brave (see its comment): Chromium doesn't safely merge
      # the same managed policy across two separate *.json files.
    };

    homeManager = { pkgs, lib, config, user, osConfig, ... }:
      let
        agentSocket = "${config.home.homeDirectory}/.ssh/proton-pass-agent.sock";
        # Match the credential backend to the host's keyring service.
        keyringEnvironment =
          if osConfig.services.gnome.gnome-keyring.enable then {
            PROTON_PASS_KEY_PROVIDER = "keyring";
            PROTON_PASS_LINUX_KEYRING = "dbus";
          } else {
            PROTON_PASS_KEY_PROVIDER = "fs";
          };
      in
      {
        # Interactive login and the agent must use the same persistent backend.
        home.sessionVariables = keyringEnvironment // {
          SSH_AUTH_SOCK = agentSocket;
        };
        # Apps launched outside a shell (launcher, IDE) only see the systemd
        # user environment; ssh-keygen -Y sign ignores IdentityAgent.
        systemd.user.sessionVariables.SSH_AUTH_SOCK = agentSocket;

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
