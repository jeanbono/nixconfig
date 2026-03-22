# modules/users.nix — module flake-parts / NixOS
# Déclare l'option centrale modules.users utilisée par tous les modules
# de features Home Manager pour savoir quels utilisateurs configurer.
{ lib, ... }:

{
  options.modules.users = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Utilisateurs gérés par Home Manager via les modules features";
  };
}
