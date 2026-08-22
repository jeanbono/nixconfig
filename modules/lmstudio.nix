{
  den.aspects.lmstudio = {
    nixos = { ... }: {
      networking.firewall.allowedTCPPorts = [ 1234 ];
    };
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.lmstudio ];
    };
  };
}
