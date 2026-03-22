{ config, lib, ... }:

let
  cfg = config.modules.nvidia;
in
{
  options.modules.nvidia.enable = lib.mkEnableOption "Pilote NVIDIA (beta, open, modesetting)";

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      open = false;
      modesetting.enable = true;
      nvidiaSettings = true;
      powerManagement.enable = false;
    };

    boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  };
}
