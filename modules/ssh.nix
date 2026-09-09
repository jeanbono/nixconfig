{
  den.aspects.ssh.homeManager = { ... }: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
    };
    # IdentityAgent, when relevant, is injected by whichever agent aspect
    # is active (e.g. den.aspects.protonpass) — this aspect stays a plain
    # generic SSH client config and works standalone without one.
  };
}
