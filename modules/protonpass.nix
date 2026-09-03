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

      # `programs.chromium.extraOpts` (used by den.aspects.brave) can't be set
      # from here too: NixOS merges it as one opaque attrs value per key, so a
      # second module setting `extraOpts.ExtensionSettings` here would silently
      # replace brave.nix's instead of merging with it (verified via `nix eval`
      # — no error, just data loss). A separate managed-policies file is the
      # actually-safe way for two independent aspects to both contribute:
      # Brave merges every *.json under policies/managed/ itself.
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
