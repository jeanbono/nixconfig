{
  den.aspects.ssh.homeManager = { ... }: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        # Socket géré par den.aspects.protonpass, qui exporte déjà SSH_AUTH_SOCK.
        identityAgent = "~/.ssh/proton-pass-agent.sock";
      };
    };
  };
}
