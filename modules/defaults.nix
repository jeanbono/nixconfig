{ lib, ... }:
{
  systems = [ "x86_64-linux" ];

  den.default.nixos.system.stateVersion = "25.05";
  den.default.homeManager.home.stateVersion = "25.05";
  den.default.nixos.nixpkgs.config.allowUnfree = true;

  den.default.nixos.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
}
