{ inputs, hostName, config, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs hostName; };
    sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
  };
}
