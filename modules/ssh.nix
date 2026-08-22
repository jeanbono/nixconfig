{
  den.aspects.ssh.homeManager = { ... }: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        identityAgent = "~/.ssh/proton-pass-agent.sock";
      };
    };

    home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.ssh/proton-pass-agent.sock";
  };
}
