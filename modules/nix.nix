{ pkgs, lib, config, ... }:

let
  cfg = config.modules.nix;
in
{
  options.modules.nix.enable = lib.mkEnableOption "Nix flakes, auto-GC and store optimisation";

  config = lib.mkIf cfg.enable {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      max-jobs = 4;
      cores = 0;
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}
