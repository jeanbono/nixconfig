{ lib, config, ... }:

let
  cfg = config.modules.home.ssh;
in
{
  options.modules.home.ssh.enable = lib.mkEnableOption "SSH + agent 1Password";

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        identityAgent = "~/.1password/agent.sock";
      };
    };
  };
}
