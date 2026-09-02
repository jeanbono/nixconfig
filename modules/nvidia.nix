{
  den.aspects.nvidia.nixos = { config, pkgs, ... }: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      # Required for VA-API on proprietary NVIDIA: the NVIDIA driver has no
      # native VA-API support, this shim translates VA-API calls to NVDEC.
      # Without it, LIBVA_DRIVER_NAME=nvidia (set by hyprland.nix) points to
      # a missing .so — hardware decoding silently broken (e.g. Plex Desktop:
      # audio+subtitles OK but image entirely black).
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
