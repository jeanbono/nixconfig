{ lib, config, pkgs, ... }:

let
  cfg = config.modules.home.ssh;
in
{
  options.modules.home.ssh.enable = lib.mkEnableOption "SSH + agent ProtonPass CLI";

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        identityAgent = "~/.ssh/proton-pass-agent.sock";
      };
    };

    # Service systemd pour l'agent SSH ProtonPass
    systemd.user.services.protonpass-ssh-agent = {
      Unit = {
        Description = "ProtonPass CLI SSH Agent";
        After = "graphical-session.target";
      };
      Service = {
        ExecStart = "${pkgs.proton-pass-cli}/bin/pass-cli ssh-agent start --create-new-identities Pierre";
        Restart = "on-failure";
        Environment = [
          "SSH_AUTH_SOCK=%h/.ssh/proton-pass-agent.sock"
          "PROTON_PASS_KEY_PROVIDER=fs"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Configuration de l'environnement pour SSH
    home.sessionVariables = {
      SSH_AUTH_SOCK = "$HOME/.ssh/proton-pass-agent.sock";
    };
  };
}
