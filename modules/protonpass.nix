let
  protonPassId = "ghmbeldphafepmbegfdlkpapadhbakde";
  updateUrl = "https://clients2.google.com/service/update2/crx";
in
{
  den.aspects.protonpass = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        proton-pass
        proton-pass-cli
      ];

      environment.etc."brave/policies/managed/10-protonpass.json".text = builtins.toJSON {
        ExtensionSettings.${protonPassId} = {
          installation_mode = "force_installed";
          update_url = updateUrl;
          toolbar_pin = "force_pinned";
        };
      };
    };

    homeManager = { pkgs, ... }: {
      home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.ssh/proton-pass-agent.sock";

      systemd.user.services.protonpass-ssh-agent = {
        Unit = {
          Description = "ProtonPass CLI SSH Agent";
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStartPre = "${pkgs.networkmanager}/bin/nm-online -q --timeout=30";
          ExecStart = "${pkgs.proton-pass-cli}/bin/pass-cli ssh-agent start --create-new-identities Pierre";
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
