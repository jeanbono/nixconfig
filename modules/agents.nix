{
  den.aspects.agents.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [ claude-code codex herdr ];
  };
}
