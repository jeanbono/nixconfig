{
  den.aspects.razer = {
    nixos = { host, ... }: {
      hardware.openrazer = {
        enable = true;
        users = builtins.attrNames host.users;
      };
    };

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [ polychromatic ];
    };
  };
}
