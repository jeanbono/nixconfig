{ lib, config, ... }:

let
  cfg = config.modules.git;
in
{
  options.modules.git.enable = lib.mkEnableOption "Git";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.modules.users (_: { config, ... }: {
      programs.git = {
        enable = true;
        extraConfig.gpg = {
          format = "ssh";
          ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed-signers";
        };
      };
    });
  };
}
