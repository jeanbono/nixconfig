{
  den.aspects.ssh.homeManager = { ... }: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        # Socket managed by den.aspects.protonpass — also hardcoded there
        # (SSH_AUTH_SOCK), keep both in sync if this changes.
        identityAgent = "~/.ssh/proton-pass-agent.sock";
      };
    };
  };
}
