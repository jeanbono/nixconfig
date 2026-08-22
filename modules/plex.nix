{
  den.aspects.plex.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.plex-desktop ];
  };
}
