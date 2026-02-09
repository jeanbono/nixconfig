{ config, pkgs, lib, ... }:

let
  cfg = config.modules.system.nvidia;
in
{
  options.modules.system.nvidia.enable = lib.mkEnableOption "Pilote NVIDIA (beta, open, modesetting)";

  config = lib.mkIf cfg.enable {
    # Optimisation pour les GPU récents
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      open = false; # Recommandé pour les cartes récentes (RTX 2000+)
      modesetting.enable = true;
      nvidiaSettings = true;
      powerManagement.enable = false;
    };

    boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  };
}
