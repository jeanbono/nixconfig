{ pkgs, lib, config, ... }:

let
  cfg = config.modules.git;
in
{
  options.modules.git.enable = lib.mkEnableOption "Git";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.modules.users (_: { config, ... }: {
      home.packages = with pkgs; [ git ];

      programs.git = {
        enable = true;
        extraConfig.gpg = {
          format = "ssh";
          ssh.program = "${pkgs.openssh}/bin/ssh-keygen";
          ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed-signers";
        };
      };

      home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.ssh/proton-pass-agent.sock";
    });
  };
}
