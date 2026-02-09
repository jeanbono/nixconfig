{
  description = "NixOS flake (modulaire) - furnace + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;

      mkHost = hostName: system: lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs hostName; };
        modules = [
          { nixpkgs.config.allowUnfree = true; }

          # NUR overlay
          ({ ... }: { nixpkgs.overlays = [ inputs.nur.overlays.default ]; })

          # Tous les modules système (chacun activable via modules.system.<name>.enable)
          ./modules/system

          ./hosts/${hostName}
        ];
      };
    in
    {
      nixosConfigurations = {
        furnace = mkHost "furnace" "x86_64-linux";
      };
    };
}
