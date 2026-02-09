{ pkgs, lib, config, ... }:

let
  cfg = config.modules.system.nix;
in
{
  options.modules.system.nix.enable = lib.mkEnableOption "Nix flakes, auto-GC and store optimisation";

  config = lib.mkIf cfg.enable {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}
