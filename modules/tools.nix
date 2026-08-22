{
  den.aspects.tools.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [
      ripgrep
      fd
      jq
      unzip
      fastfetch
    ];
  };
}
