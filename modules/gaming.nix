{
  den.aspects.gaming.nixos = { pkgs, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

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
    ];

    # hardware.graphics.enable32Bit déjà activé par den.aspects.nvidia.
    hardware.steam-hardware.enable = true;
  };
}
