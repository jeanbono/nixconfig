{
  den.aspects.protonpass = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        proton-pass
        proton-pass-cli
      ];

      # The Brave force-install policy for the ProtonPass extension is owned
      # by den.aspects.brave (see its comment): Chromium doesn't safely merge
      # the same managed policy across two separate *.json files.
    };

    homeManager = { pkgs, user, ... }: {
      home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.ssh/proton-pass-agent.sock";

      programs.ssh.settings."*".identityAgent = "~/.ssh/proton-pass-agent.sock";

      systemd.user.services.protonpass-ssh-agent = {
        Unit = {
          Description = "ProtonPass CLI SSH Agent";
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStartPre = "${pkgs.networkmanager}/bin/nm-online -q --timeout=30";
          ExecStart = "${pkgs.proton-pass-cli}/bin/pass-cli ssh-agent start --create-new-identities ${user.protonPassIdentity}";
          Restart = "on-failure";
          RestartSec = "5s";
          Environment = [
            "SSH_AUTH_SOCK=%h/.ssh/proton-pass-agent.sock"
            "PROTON_PASS_KEY_PROVIDER=fs"
          ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
