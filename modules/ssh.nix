{ lib, config, ... }:

let
  cfg = config.modules.ssh;
in
{
  options.modules.ssh.enable = lib.mkEnableOption "Configuration SSH cliente";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.modules.users (_: {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings."*" = {
          identityAgent = "~/.ssh/proton-pass-agent.sock";
        };
      };

      home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.ssh/proton-pass-agent.sock";
    });
  };
}
