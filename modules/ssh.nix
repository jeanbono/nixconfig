{
  den.aspects.ssh.homeManager = { ... }: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        # Socket managed by den.aspects.protonpass, which already exports SSH_AUTH_SOCK.
        identityAgent = "~/.ssh/proton-pass-agent.sock";
      };
    };
  };
}
