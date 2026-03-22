# flake-module.nix — module flake-parts racine (pattern dendritic)
#
# Chaque fichier sous modules/ est un module flake-parts (top-level).
# Ces modules contribuent à flake.nixosModules et/ou flake.homeModules
# pour décrire une feature qui s'applique aux deux couches à la fois.
{ inputs, lib, ... }:

let
  # Auto-import de tous les fichiers .nix sous modules/ (récursif, sauf default.nix)
  # dir doit être un path Nix (ex: ./modules)
  importTree = dir:
    let
      entries = builtins.readDir dir;
      handle = name: type:
        if type == "directory" then
          importTree (dir + "/${name}")
        else if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" then
          [ (dir + "/${name}") ]
        else
          [];
    in
    lib.concatLists (lib.mapAttrsToList handle entries);

  allModules = importTree ./modules;

  mkHost = { hostName, system ? "x86_64-linux" }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules =
        # Tous les modules flake-parts sont des modules NixOS valides
        # (ils exposent options.modules.* et configurent config.*)
        allModules
        ++ [
          { nixpkgs.config.allowUnfree = true; }
          {
            nixpkgs.overlays = [
              inputs.cachyos.overlays.pinned
              inputs.nur.overlays.default
            ];
          }
          # Module home-manager (injection de l'intégration HM)
          inputs.home-manager.nixosModules.home-manager
          ({ config, ... }: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { nixosConfig = config; };
              sharedModules = [
                inputs.plasma-manager.homeModules.plasma-manager
                inputs.caelestia-shell.homeManagerModules.default
              ];
            };
          })
          # Config spécifique au host (hardware, users, options activées)
          ./hosts/${hostName}
        ];
    };
in
{
  flake.nixosConfigurations = {
    furnace = mkHost { hostName = "furnace"; };
  };
}
