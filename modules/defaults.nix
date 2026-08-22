{ inputs, lib, ... }:
{
  systems = [ "x86_64-linux" ];

  den.default.nixos.system.stateVersion = "25.05";
  den.default.homeManager.home.stateVersion = "25.05";
  den.default.nixos.nixpkgs.config.allowUnfree = true;

  den.default.nixos.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      inputs.caelestia-shell.homeManagerModules.default
      inputs.nixvim.homeModules.nixvim
    ];
  };

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
}
