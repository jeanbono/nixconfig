{
  den.aspects.razer = {
    nixos = { ... }: {
      hardware.openrazer = {
        enable = true;
        users = [ "pierre" ];
      };
    };

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [ polychromatic ];
    };
  };
}
