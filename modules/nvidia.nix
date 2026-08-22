{
  den.aspects.nvidia.nixos = { config, pkgs, ... }: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      # Requis pour VA-API sur NVIDIA propriétaire : le driver NVIDIA n'a pas
      # de support VA-API natif, ce shim traduit les appels VA-API vers NVDEC.
      # Sans lui, LIBVA_DRIVER_NAME=nvidia (défini par hyprland.nix) pointe
      # vers un .so absent — décodage matériel silencieusement cassé (ex:
      # Plex Desktop : son+sous-titres OK mais image entièrement noire).
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
