{
  den.aspects.nvidia.nixos = { config, ... }: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
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
