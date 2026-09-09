{
  den.aspects.gaming.nixos = { pkgs, ... }: {
    programs.steam.enable = true;

    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      faugus-launcher
      mangohud
      gamemode
      protonplus
      vulkan-tools
      wineWow64Packages.stable
      winetricks
      ntfs3g
      r2modman
    ];

    # hardware.graphics.enable32Bit already enabled by den.aspects.nvidia.
    hardware.steam-hardware.enable = true;
  };
}
