{ pkgs, lib, config, ... }:

let
  cfg = config.modules.protonpass;
  protonPassId = "ghmbeldphafepmbegfdlkpapadhbakde";
  updateUrl = "https://clients2.google.com/service/update2/crx";
in
{
  options.modules.protonpass.enable = lib.mkEnableOption "ProtonPass CLI + GUI";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      proton-pass
      proton-pass-cli
    ];

    home-manager.users = lib.genAttrs config.modules.users (_: {
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
    });

    # Contribue sa propre policy Brave si Brave est activé, sans écrire dans brave.nix
    environment.etc."brave/policies/managed/10-protonpass.json" =
      lib.mkIf config.modules.brave.enable {
        text = builtins.toJSON {
          ExtensionSettings.${protonPassId} = {
            installation_mode = "force_installed";
            update_url = updateUrl;
            toolbar_pin = "force_pinned";
          };
        };
      };
  };
}
