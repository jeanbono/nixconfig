{
  den.aspects.nvidia.nixos = { config, pkgs, ... }: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      # Provides the VA-API to NVDEC bridge for LIBVA_DRIVER_NAME=nvidia.
      extraPackages = [ pkgs.nvidia-vaapi-driver ];
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      open = false;
      modesetting.enable = true;
      nvidiaSettings = true;
      powerManagement.enable = false;
    };

    boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  };
}
